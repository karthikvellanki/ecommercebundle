require "capybara"
require "capybara/poltergeist"
class Product < ApplicationRecord
	include PgSearch

  # money
  monetize :price_cents
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :group_products, dependent: :destroy
  # associations
  has_many :pictures, as: :picturable, dependent: :destroy
  belongs_to :category
  belongs_to :supplier_category
  before_destroy :remove_order_items
  belongs_to :user
  belongs_to :provider
  has_many :demands
  has_many :inventory, dependent: :destroy
  has_many :supplier_bids, dependent: :destroy
  has_many :scrap_results, :dependent => :destroy
  has_many :request_quotes, dependent: :destroy
  has_many :aggregation_rounds, inverse_of: :product, dependent: :destroy
  attr_accessor :discount

  store_accessor :technical_specifications
  store_accessor :meta, :barcode_value1, :barcode_value2

  accepts_nested_attributes_for :aggregation_rounds, reject_if: :all_blank, allow_destroy: true

  # paperclip
  has_attached_file :image, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: 'http://www.identdentistry.ca/identfiles/no_image_available.png'
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  scope :product_type_filter, lambda{ |product_type_filter|
                                where(category_id: product_type_filter) if not product_type_filter.blank?
                              }


  scope :store_front_filter, lambda {|option|
    return nil if option.blank?
    where(storefront_option: option)
  }

  scope :product_filter, lambda {|category_id|
    return nil if category_id.blank?
    where(category_id: category_id)
  }

  scope :store_front_products, -> {where(storefront_option: true)}

  pg_search_scope :search, :against => [[:name, "A"], [:sku, "B"]], using:{
    tsearch: {
      prefix: true,
      dictionary: "english",
      any_word: true,
    }
  } 

  scope :old_search, lambda { |query|
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(products.name) LIKE ? OR LOWER(products.sku) LIKE ? )"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }
  def has_inventory?(user)
    inventory = Inventory.where(user:user,product: self).first
    return !inventory.nil?
  end

  def comment1
    #search_bar
    pg_search_scope :search, :against => [ [:name, "A"], [:sku, "B"] ], using: {
      tsearch: {
        prefix: true,
        dictionary: "english",
        any_word: true,
      }
    }
  end

  def remove_order_items
    self.order_items.clear
  end

  def group_price(user_id)
    current_user = User.find(user_id)
		groups = current_user.supplier.supplier_groups.joins(:customers).where(users: {id: user_id}).where(provider_id: current_user.try(:supplier).try(:id))
		if groups.present?
			group_ids = groups.pluck(:id)
			group_products = GroupProduct.where(product_id: self.id, group_id: group_ids)
			if group_products.present?
				return group_products.last.price
			else
				return self.price
			end
		else
			return self.price
		end
	end

	def is_group_product(user_id)
		current_user = User.find(user_id)
		groups = current_user.supplier.supplier_groups.joins(:customers).where(users: {id: user_id}).where(provider_id: current_user.try(:supplier).try(:id))
		if groups.present?
			group_ids = groups.pluck(:id)
			group_products = GroupProduct.where(product_id: self.id, group_id: group_ids)
			if group_products.present?
				return true
			else
				return false
			end
		else
			return false
		end
	end

end

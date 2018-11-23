class RequestQuote < ApplicationRecord
	belongs_to :user
	belongs_to :provider
	belongs_to :product
  has_many :supplier_bids, dependent: :destroy
  has_many :suppliers, through: :supplier_bids, foreign_key: "supplier_id" 
  paginates_per 2

  def product_name
    if self.product
      return self.product.name
    end
    return self[:product_name]
  end
end

class Order < ApplicationRecord
  enum status: [:placed, :fulfilled, :paid, :unpaid]

  before_save :order_status, :if => :new_record?
  paginates_per 10
  scope :search, lambda { |query|
		return nil  if query.blank?
  	# Searches the students table on the 'first_name' and 'last_name' columns.
  	# Matches using LIKE, automatically appends '%' to each term.
  	# LIKE is case INsensitive with MySQL, however it is case
  	# sensitive with PostGreSQL. To make it work in both worlds,
  	# we downcase everything.
  	# condition query, parse into individual keywords
  	terms = query.downcase.split(/\s+/)

  	# replace "*" with "%" for wildcard searches,
  	# append '%', remove duplicate '%'s
  	terms = terms.map { |e|
  		(e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
  	}
  	# configure number of OR conditions for provision
  	# of interpolation arguments. Adjust this if you
  	# change the number of OR conditions.
  	num_or_conds = 4
  	where(
  		terms.map { |term|
  			"(LOWER(orders.first_name) LIKE ? OR LOWER(orders.last_name) LIKE ? OR LOWER(orders.email) LIKE ? OR CAST(orders.mobile_number AS TEXT) LIKE ?)"
  		}.join(' AND '),
  		*terms.map { |e| [e] * num_or_conds }.flatten
  	)
  }
  scope :status_filter, lambda{ |status_filter|
  		return nil if status_filter.blank?
  		where(status: status_filter)
  	}
  scope :payment_type_filter, lambda{ |payment_type_filter|
		return nil if payment_type_filter.blank?
		where("payment_details ->> 'payment_mode' = ?", payment_type_filter)
	}
  scope :searchid, lambda { |query|
		return nil  if query.blank?
	# Searches the students table on the 'first_name' and 'last_name' columns.
	# Matches using LIKE, automatically appends '%' to each term.
	# LIKE is case INsensitive with MySQL, however it is case
	# sensitive with PostGreSQL. To make it work in both worlds,
	# we downcase everything.
	# condition query, parse into inpayment_typedividual keywords
	terms = query.downcase.split(/\s+/)

	# replace "*" with "%" for wildcard searches,
	# append '%', remove duplicate '%'s
	terms = terms.map { |e|
		(e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
	}
	# configure number of OR conditions for provision
	# of interpolation arguments. Adjust this if you
	# change the number of OR conditions.
	num_or_conds = 1
	where(
		terms.map { |term|
			"(CAST(orders.id as TEXT) LIKE ? )"
		}.join(' AND '),
		*terms.map { |e| [e] * num_or_conds }.flatten
	)
  }
  scope :date_filter, lambda{|start_date, end_date|
    return nil if start_date.blank? && end_date.blank?
    if start_date.blank?
      start_date = beginning_of_year(2015)
    end
    if end_date.blank?
      end_date = DateTime.now
    end
    where(created_at: start_date..end_date)
  }

  has_many :order_items, dependent: :destroy, inverse_of: :order
  belongs_to :user
  has_many :addresses, as: :addressable, dependent: :destroy

  def admin_order_items current_user
    if current_user.is_provider
      return order_items.where(provider_id: current_user.provider.id)
    end
    order_items
  end

  require 'json'

  monetize :total_price_cents, :sub_total_cents, :shipping_charges_cents, :other_charges_cents, :sales_tax_total_cents
  validates_presence_of :first_name, :last_name, :email

  accepts_nested_attributes_for :order_items

  scope :latest_created_first, -> {order(created_at: :desc)}

    def sub_total_cents
        sum = 0
        self.order_items.each do |order_item|
            sum += (order_item.price_cents*order_item.quantity)
        end
        return sum
    end

    def sales_tax_total_cents
      if not self.sales_tax.nil? and self.sales_tax > 0.0
        return (self.sub_total_cents * self.sales_tax / 100).round
      end
      return 0
    end

    def recalcuate_order_total
        total = self.sub_total_cents
        total += self.sales_tax_total_cents
        if not self.shipping_charges_cents.nil? and self.shipping_charges_cents > 0
          total += self.shipping_charges_cents
        end
        if not self.other_charges_cents.nil? and self.other_charges_cents > 0
          total += self.other_charges_cents
        end
        self.total_price_cents = total
        save!
    end

    def cash_on_delivery
        self.payment_mode = 'Cash On Delivery'
        #self.status = self.class.statuses[:pending]
        self.save!
        #OrderCreationNotificationsJob.perform_later self.id
        #OrderPlacedJob.perform_later self.id
    end

    def online_payment
        #self.status = self.class.statuses[:confirmed]
        self.save!
        #OnlinePaymentOrderConfirmationNotificationsJob.perform_later self.id
        #OrderPlacedJob.perform_later self.id
    end

  def provider
    oi = self.order_items.first
    if not oi.nil? and not oi.provider.nil?
      return oi.provider
    end
    return nil
  end

 def self.save_with_payment(email,token,order_id,charge)
    customer = Stripe::Customer.create(email: email, source: token)
    Order.find(order_id).user.update(customer_id: customer.id)
    order = Order.find(order_id)
    provider = order.order_items.last.provider
    charge = Stripe::Charge.create({
              amount:  charge.to_i,
              destination: provider.user.stripe_user_id,
              currency: 'usd',
              description: 'Bundle charges',
              customer: customer.id
            })
    return customer.id
  end

  def self.payment_only(order_id,charge_amount,stripe_customer_id)
    order = Order.find(order_id)
    # Find the user to pay.
    user = order.order_items.last.provider.user
    Stripe.api_key = Rails.application.secrets.stripe_secret_key

    providers = order.order_items.map(&:provider).uniq

    providers.each do |provider|
      price_cents = order.order_items.where(provider_id: provider.id).sum(:price_cents)
      charge = Stripe::Charge.create({
                amount:  price_cents.to_i,
                destination: provider.user.stripe_user_id,
                currency: 'usd',
                description: 'Bundle charges',
                customer: stripe_customer_id
              })

      order.update(payment_details: charge, status: :paid)
      price_cents = 0
    end
  end

  def order_status
    self.status = :placed
  end


  def update_to_fulfilled
    self.status = :fulfilled
    self.save
  end
end

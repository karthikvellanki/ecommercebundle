class Cart < ApplicationRecord

  #associations
  has_many :cart_items, -> { order(created_at: :desc) }, dependent: :destroy
  belongs_to :user
  belongs_to :provider

  #price_cents
  monetize :total_price_cents
  monetize :instant_total_price_cents
  monetize :invoice_total_price_cents
  accepts_nested_attributes_for :cart_items, allow_destroy: true

  def instant_total_price_cents
		sum = 0;
		cart_items_instant.each do |cart_item|
			sum += cart_item.total_price_cents
		end
		return sum
	end

  def invoice_total_price_cents
		sum = 0;
		cart_items_invoice.each do |cart_item|
			sum += cart_item.total_price_cents
		end
		return sum
	end

  def total_price_cents
		sum = 0;
		cart_items.each do |cart_item|
			sum += cart_item.total_price_cents
		end
		return sum
	end

  
  def cart_items_instant
    cart_items = CartItem.where(cart: self).joins(:product)
    ci_instant = []
    cart_items.each do |x| 
      inventory = Inventory.where(product: x.product, user: self.user).first 
      if (x.product.storefront_option and not (not inventory.nil? and inventory.is_invoice) )
        ci_instant.push x
      end
    end
    return ci_instant
  end

  def cart_items_invoice
    cart_items = CartItem.where(cart: self).joins(:product)
    ci_invoice = []
    cart_items.select {|x| 
      inventory = Inventory.where(product: x.product, user: self.user).first 
      if (not x.product.storefront_option or (not inventory.nil? and inventory.is_invoice) )
        ci_invoice.push x
      end
    }
    return ci_invoice
  end

end

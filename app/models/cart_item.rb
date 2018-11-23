class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :provider
  monetize :total_price_cents
  monetize :price_cents
  #validates :quantity, :numericality => {greater_than: 0}, presence: true

  def total_price_cents
    self.price_cents * self.quantity
  end

  def price_cents
  	if self.product.is_group_product(self.cart.user.id)
  		return self.product.group_products.last.price_cents
  	else 
	    return self.product.price_cents 
	    ci = Inventory.where(product: self.product,user: self.cart.user).first
	    if ci.nil?
	      return self.product.price_cents 
	    else
	      return ci.price_cents 
	    end
	  end
  end

  def product_name
  	return Product.find(self.product_id).name
  end

  def get_product_preview
     return self.product.image
  end

  private
    def self.update_cart(cart, product_id, quantity=1, price_cents=0, provider=nil, force_quantity=false)
        if cart_item = cart.cart_items.find_by(product_id: product_id,provider: provider)
            if force_quantity
              cart_item.quantity = quantity
            else 
              cart_item.quantity += quantity
            end
            cart_item.price_cents = price_cents
            if cart_item.save
                return cart
            else
                return false
            end
        elsif cart.cart_items.create(product_id: product_id,quantity:quantity,price_cents: price_cents,provider: provider)
            return cart
        else
            return false
        end
    end
end

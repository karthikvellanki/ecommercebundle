class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :provider
  belongs_to :order, inverse_of: :order_items
  monetize :price_cents
  monetize :order_item_total_price_cents
  after_commit :decrement_product_inventory_count, on: :create
  
  enum status: { received: 0, shipped: 1 }

  def status
    super.to_s.humanize
  end

  def order_item_total_price_cents
   	return self.price_cents * self.quantity
  end

  def decrement_product_inventory_count
    product.inventory_count -= 1
    product.save!
  end
end

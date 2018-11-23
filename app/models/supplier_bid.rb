class SupplierBid < ApplicationRecord
  belongs_to :bid
  belongs_to :product
  belongs_to :request_quote
  belongs_to :supplier, class_name: 'User', foreign_key: "supplier_id"

  monetize :price_cents

  def price_cents
    if self.product
      return self.product.price_cents
    end
    return self[:price_cents]
  end
  
  def accepted?
    status == "accepted"
  end
end

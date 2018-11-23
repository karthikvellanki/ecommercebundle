class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :cart_id, :product_id, :quantity, :price_cents, :total_price_cents, :product_name

  belongs_to :cart
  belongs_to :product
  belongs_to :provider
end

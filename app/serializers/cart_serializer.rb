class CartSerializer < ActiveModel::Serializer
  attributes :id, :active, :total_price_cents

  has_many :cart_items, dependent: :destroy
end

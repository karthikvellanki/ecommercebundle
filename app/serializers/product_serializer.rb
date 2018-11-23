class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price_cents, :sku, :unit, :barcode_value, :brand, :supplier_category_id
  
  has_many :cart_items, dependent: :destroy
  belongs_to :supplier_category
end

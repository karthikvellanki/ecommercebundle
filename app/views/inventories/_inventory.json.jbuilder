json.extract! inventory, :id, :quantity,:product_id, :capacity,:threshold,:description,:name,:barcode, :picture_id,:picture, :user_id,  :created_at, :updated_at
#json.url inventory_url(inventory, format: :json)
json.price humanized_money_with_symbol inventory.price
ci = CollectionInventory.where(inventory: inventory).first
if ci.nil?
  json.collection_id -1
else
  json.collection_id ci.collection.id
  json.collection ci.collection
end
if not inventory.product.nil?
  json.sku inventory.product.sku
end

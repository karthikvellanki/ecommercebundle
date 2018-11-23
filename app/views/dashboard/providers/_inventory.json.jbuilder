json.extract! inventory, :id, :quantity,:product_id,:capacity,:threshold,:description,:name,:barcode, :picture_id,:picture, :user_id,  :created_at, :updated_at
json.url inventory_url(inventory, format: :json)

ci = CollectionInventory.where(inventory: inventory).first
if ci.nil?
  json.collection_id -1
else
  json.collection_id ci.collection.id
  json.collection ci.collection
end
if inventory.product and inventory.product.amazon_id
  json.amazon_id = inventory.product.amazon_id
end  


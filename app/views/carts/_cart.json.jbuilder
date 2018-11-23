json.extract! cart, :id, :active, :created_at, :updated_at
json.total_price humanized_money_with_symbol cart.total_price
json.url cart_url(cart, format: :json)

if cart.provider.nil?
  json.supplier do  
    json.name "Bundle"
  end
else
  json.supplier cart.provider
end

json.cart_items cart.cart_items do |cart_item|
  json.extract! cart_item, :id, :quantity, :created_at, :updated_at
  json.price humanized_money_with_symbol cart_item.price
  json.total_price humanized_money_with_symbol cart_item.price * cart_item.quantity
  json.name cart_item.product.name
end


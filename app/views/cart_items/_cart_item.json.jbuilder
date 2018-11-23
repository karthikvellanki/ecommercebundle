json.extract! cart_item, :id, :cart_id, :quantity, :created_at, :updated_at
json.price humanized_money_with_symbol cart_item.price
json.total_price humanized_money_with_symbol cart_item.price * cart_item.quantity
json.cart_total_price humanized_money_with_symbol cart_item.cart.total_price
json.name cart_item.product.name
json.url cart_item_url(cart_item, format: :json)

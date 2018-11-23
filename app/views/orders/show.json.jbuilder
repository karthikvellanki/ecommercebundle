json.extract! @order, :id, :user_id, :email, :first_name, :last_name, :mobile_number 
json.total_price humanized_money_with_symbol @order.total_price
json.url order_url(@order, format: :json)
json.date @order.order_date.strftime "%m-%d-%Y"

if not @order.order_items.first.nil?
  json.supplier @order.order_items.first.provider
end

json.order_items @order.order_items do |order_item|
  json.extract! order_item, :id, :status, :quantity, :created_at, :updated_at
  json.price humanized_money_with_symbol order_item.price
  json.total_price humanized_money_with_symbol order_item.price * order_item.quantity
  json.name order_item.product.name
end


json.array!(@orders) do |order|
  json.extract! order, :id, :user_id, :email, :first_name, :last_name, :mobile_number,   :total_price_cents
  json.url order_url(order, format: :json)
	
  if not order.order_items.first.nil?
    json.supplier order.order_items.first.provider
  end
  json.date order.order_date.strftime "%m-%d-%Y"
end

json.extract! request_quote, :id, :product_name, :item_number, :description, :quantity, :created_at, :updated_at
json.url request_quote_url(request_quote, format: :json)

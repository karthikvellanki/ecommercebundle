json.extract! quote_request, :id, :name, :email, :mobile_number, :category, :created_at, :updated_at
json.url quote_request_url(quote_request, format: :json)

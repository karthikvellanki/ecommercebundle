json.extract! address, :id, :line_1, :line_2, :line_3, :city, :state, :pincode, :name, :address_type, :created_at, :updated_at
json.url address_url(address, format: :json)
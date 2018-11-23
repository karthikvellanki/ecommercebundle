json.extract! subscription, :id, :email, :product_id, :created_at, :updated_at
json.url subscription_url(subscription, format: :json)
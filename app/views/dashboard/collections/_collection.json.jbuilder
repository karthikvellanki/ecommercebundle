json.extract! collection, :id, :name, :description, :created_at, :updated_at, :picture, :picture_id,:user_id, :category_id
json.url collection_url(collection, format: :json)

json.extract! page, :id, :title, :content, :url, :provider_id, :created_at, :updated_at
json.url page_url(page, format: :json)

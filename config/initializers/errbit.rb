Airbrake.configure do |config|
  config.host = 'https://errors.commutatus.com'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = 'b6225ba43b7f8f0d7f41bbdca595e2ca'

  # Uncomment for Rails apps
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end

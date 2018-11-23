require_relative 'boot'

require 'rails/all'
require 'aws-sdk'

Aws.config.update({
  region: '',
  credentials: Aws::Credentials.new('', '')
})

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bundle
  class Application < Rails::Application
    if Rails.env.development?
      config.web_console.whitelisted_ips = '192.168.0.0/16'
    end
    config.assets.enabled = true
    config.public_file_server.enabled = true
    # config.serve_static_files = true
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.precompile += %w( *-bundle.js )
  	config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.session_store(:cookie_store, {:key => '_groupscale_session', :secret => Rails.configuration.secret_key_base, domain: :all, tld_length: 2})
  end
end

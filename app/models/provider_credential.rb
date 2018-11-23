require 'openssl'

class ProviderCredential < ApplicationRecord
  belongs_to :user
  belongs_to :provider
  attr_encrypted :password, key: ENV['BUNDLE_KEY']
  
end

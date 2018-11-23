require "capybara"
require "capybara/poltergeist"

class Provider < ApplicationRecord
  attr_accessor :credential
  extend FriendlyId
  friendly_id :slug_name, use: :slugged

  belongs_to :user
  has_many :customers, :class_name => 'User', :foreign_key => 'provider_id', :dependent => :destroy

  has_many :request_quotes, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :user_provider_mappings, :dependent => :destroy

  has_many :supplier_groups, :class_name => 'Group', :foreign_key => 'provider_id', :dependent => :destroy

  store_accessor :meta, :domain_name, :ns1, :ns2, :ns3, :ns4

  #callback
  after_create :create_slug_name
  after_create :create_aws_record_set, :verify_provider_ses unless Rails.env.development?

  after_commit :destroy_aws_record_set, on: :destroy unless Rails.env.development?

  has_attached_file :image, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: 'http://www.identdentistry.ca/identfiles/no_image_available.png'
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  def as_json(options = { })
    h = super(options)
    h["image_url"] = self.image.url
    h
  end

  def create_slug_name
  	self.update_attributes(slug_name: self.user.name.gsub(' ',''))
  end

  def create_aws_record_set
    Aws.config.update({
      region: 'us-west-2',
      credentials: Aws::Credentials.new('', '')
    })
    client =  Aws::Route53::Client.new()
    resp = client.change_resource_record_sets({change_batch: {changes: [{action: "CREATE", resource_record_set: {name: "#{self.slug}.orderbundle.com", resource_records: [{value: "54.201.4.4", }, ], ttl: 60, type: "A", }, }, ], comment: "Web server for orderbundle.com", }, hosted_zone_id: "Z2B4N3RN0AU4E9", })
  end

  def destroy_aws_record_set
    Aws.config.update({
      region: 'us-west-2',
      credentials: Aws::Credentials.new('', '')
    })
    client =  Aws::Route53::Client.new()
    resp = client.change_resource_record_sets({change_batch: {changes: [{action: "DELETE", resource_record_set: {name: "#{self.slug}.orderbundle.com", resource_records: [{value: "54.201.4.4", }, ], ttl: 60, type: "A", }, }, ], comment: "Web server for orderbundle.com", }, hosted_zone_id: "Z2B4N3RN0AU4E9", })
  end



  def verify_provider_ses
    Aws.config.update({
      region: 'us-west-2',
      credentials: Aws::Credentials.new('', '')
    })
    client = Aws::SES::Client.new()
    resp = client.verify_email_identity({
      email_address: self.user.email,
    })
  end

  def is_manual?
    not user.nil?
  end

  def is_connected(user)
    if ProviderCredential.where(provider: self,user: user).first.nil?
      return false
    end
    return true
  end



  def validate_credentials(username,password)
    session = Provider.get_session
    valid = self.get_class.validate_credentials(session,username,password)
    Provider.wind_up session
    return valid
  end

  def self.add_to_cart(product_id,user_id,provider_id,quantity)
    provider = Provider.friendly.find provider_id
    browser = get_session
	begin
      provider.get_class.add_to_cart(browser,product_id,user_id,provider,quantity)
    rescue => e
      ExceptionNotifier.notify_exception(e,
	      :data => {:product => product_id, :user => user_id, :provider => provider.user.company})
    end
    wind_up browser
  end

  def self.fetch_delayed(product_id,user_id,provider_id)
    provider = Provider.friendly.find provider_id
    result = nil
    session = get_session
    begin
      result = [provider.as_json] + provider.get_class.fetch(session,product_id,user_id,provider)
    rescue => e
      ExceptionNotifier.notify_exception(e,
	      :data => {:product => product_id, :user => user_id, :provider => provider.user.company})
    end
    wind_up session
    scrap_result = ScrapResult.where(user_id:user_id,product_id:product_id,provider_id:provider_id).first
    scrap_result.with_lock do
      if result
        scrap_result.result = result
        scrap_result.status = "completed"
      else
        scrap_result.status = "failed"
      end
      scrap_result.save
    end
  end


  def self.get_session
    Capybara.javascript_driver = :poltergeist
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {timeout:60,js_errors: false, phantomjs_options: ['--ssl-protocol=any','--load-images=no', '--ignore-ssl-errors=yes'],})
    end
    Capybara.default_driver = :poltergeist

    session = Capybara::Session.new(Capybara.current_driver)
  end

  def self.wind_up(session)
    session.driver.quit
  end
end

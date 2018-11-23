class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, authentication_keys: [:email, :store_name]

  #enum
  enum sex: [:male, :female]
  enum shipping_choice: [:use_my_shipping_account_number, :use_supplier_shipping_method]
  has_many :addresses, as: :addressable
  has_many :subscriptions, inverse_of: :user
  has_many :orders, dependent: :destroy
  has_many :bank_accounts
  has_many :products
  has_many :inventories
  has_many :collections
  has_many :carts
  has_many :user_provider_mappings, :dependent => :destroy
  has_one :provider, :dependent => :destroy # this is supplier's account - user who maintains their products from supplier panel
  has_many :request_quotes
  has_many :supplier_bids, foreign_key: "supplier_id"
  has_many :bids, through: :supplier_bids
  belongs_to :supplier, optional: true, :class_name => 'Provider', :foreign_key => 'provider_id' # this is the supplier account where this self signed up as a user.

  has_many :customer_groups, :dependent => :destroy
	has_many :groups, through: :customer_groups


  #nested_field
  accepts_nested_attributes_for :provider

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "https://s3-ap-southeast-1.amazonaws.com/commutatus-cdn/bundle/user.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  serialize :stripe_account_status, JSON

  #custom validations for users
  validates_uniqueness_of :email, scope: :provider_id
  validates_presence_of   :email, if: :email_required?
  validates_format_of     :email, with: /\A[^@]+@[^@]+\z/, if: :email_changed?

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: 8..128, allow_blank: true

  # General 'has a Stripe account' check
  def connected?; !stripe_user_id.nil?; end

  # Stripe account type checks
  def managed?; stripe_account_type == 'managed'; end
  def standalone?; stripe_account_type == 'standalone'; end
  def oauth?; stripe_account_type == 'oauth'; end

  def manager
    case stripe_account_type
    when 'managed' then StripeManaged.new(self)
    when 'standalone' then StripeStandalone.new(self)
    when 'oauth' then StripeOauth.new(self)
    end
  end

  def can_accept_charges?
    return true if oauth?
    return true if managed? && stripe_account_status['charges_enabled']
    return true if standalone? && stripe_account_status['charges_enabled']
    return false
  end

  def name
    return self.first_name.to_s.capitalize + " " + self.last_name.to_s.capitalize
  end

  def company
    return self[:company].nil? ? "" : self[:company]
  end

  def id_dict
    data = {}
    data["id"] = self.id
    data["name"] = self.name
    data["company"] = self.company
    data["email"] = self.email
    data
  end

  def is_provider
    not self.provider.nil?
  end

  def profile_picture_url
  	avatar = self.avatar
  	return  "https:#{avatar}"
  end

  scope :search, lambda { |query|
   return nil  if query.blank?
 # Searches the students table on the 'first_name' and 'last_name' columns.
 # Matches using LIKE, automatically appends '%' to each term.
 # LIKE is case INsensitive with MySQL, however it is case
 # sensitive with PostGreSQL. To make it work in both worlds,
 # we downcase everything.
 # condition query, parse into individual keywords
 terms = query.downcase.split(/\s+/)

 # replace "*" with "%" for wildcard searches,
 # append '%', remove duplicate '%'s
 terms = terms.map { |e|
   (e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
 }
 # configure number of OR conditions for provision
 # of interpolation arguments. Adjust this if you
 # change the number of OR conditions.
 num_or_conds = 4
 where(
   terms.map { |term|
     "(LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ? OR LOWER(users.email) LIKE ? OR CAST(mobile AS TEXT) LIKE ?)"
   }.join(' AND '),
   *terms.map { |e| [e] * num_or_conds }.flatten
   )
  }

   #scopes
   scope :latest_created_at, ->{order(created_at: :desc)}

  def send_welcome_email
    SendWelcomeEmailJob.perform_later self.id
  end

  def generate_reset_pwd_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    return raw
  end

  def auth_token
    payload = {}
    payload["user_id"] = self.id
    JWT.encode(payload,ENV['JWT_KEY'])
  end

  def self.validate_token(token)
    payload = HashWithIndifferentAccess.new(JWT.decode(token, ENV['JWT_KEY'])[0])
    return self.find payload["user_id"]
  rescue
    nil
  end

  protected

  # From Devise module Validatable
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  # From Devise module Validatable
  def email_required?
    true
  end
end

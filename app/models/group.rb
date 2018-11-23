class Group < ApplicationRecord
  belongs_to :provider
  has_many :customer_groups, dependent: :destroy
	has_many :customers, through: :customer_groups, source: :user, dependent: :destroy
	has_many :group_products, dependent: :destroy
	has_many :products, through: :group_products, dependent: :destroy

  validates_presence_of   :name

end

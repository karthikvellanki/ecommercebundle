class ScrapResult < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :provider
  serialize :result, Array

end

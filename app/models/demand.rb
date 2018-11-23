class Demand < ApplicationRecord
  belongs_to :aggregation_round
  #money
  monetize :price_cents
end

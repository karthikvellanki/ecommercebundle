class AggregationRound < ApplicationRecord
  belongs_to :product
  enum status: [:active, :expired, :fulfilled]
end

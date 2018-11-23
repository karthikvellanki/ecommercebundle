class GroupProduct < ApplicationRecord
  belongs_to :product
  belongs_to :group

  monetize :price_cents
end

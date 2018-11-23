class CollectionInventory < ApplicationRecord
  belongs_to :collection
  belongs_to :inventory
end

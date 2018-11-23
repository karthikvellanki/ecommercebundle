class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :picture
  belongs_to :category

  accepts_nested_attributes_for :picture, reject_if: :all_blank, allow_destroy: true

  def as_json(options = { })
    h = super(options)
    h["picture"] = self.picture
    h
  end
end

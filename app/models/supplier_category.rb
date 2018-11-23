class SupplierCategory < ApplicationRecord
	belongs_to :parent, class_name: 'SupplierCategory', foreign_key: 'parent_id'
	has_many :children, class_name: 'SupplierCategory', foreign_key: 'parent_id'
	has_many :products
	belongs_to :provider
	has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "http://www.identdentistry.ca/identfiles/no_image_available.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
end

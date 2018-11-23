class Photo < ApplicationRecord
	include ImageUploader[ :image ]
	# include ::ImageUploader::Attachment.new(:image)

end

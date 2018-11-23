class QuoteRequest < ApplicationRecord
	belongs_to :category

	#paperclip
	has_attached_file :upload_file, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment :upload_file, content_type: { content_type: ["application/pdf", "application/doc", "application/docx",
    "image/jpeg", "image/gif", "image/png", "image/jpg", "image/bmp"] }
end

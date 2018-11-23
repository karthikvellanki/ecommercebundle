class Picture < ApplicationRecord
    #associations
  belongs_to :picturable, polymorphic: true

  #paperclip
  has_attached_file :picture_file, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.jpg", :s3_protocol => :https
  validates_attachment_content_type :picture_file, content_type: /\Aimage\/.*\Z/

  def original_url
      return self.picture_file.url
  end

  def medium_url
    return self.picture_file.url(:medium)
  end

  def as_json(options = { })
    h = super(options)
    h["url"] = self.medium_url
    h
  end

end

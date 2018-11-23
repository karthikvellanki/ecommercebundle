class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :mobile, :avatar, :profile_picture_url

  has_one :provider
  has_many :carts

end

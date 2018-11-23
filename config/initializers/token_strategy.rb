Warden::Strategies.add(:token) do 
  def valid? 
	request.headers['Authorization'].present?
  end
  def authenticate!
	token = request.headers['Authorization'].split(' ').last
	u = User.validate_token(token)
	u.nil? ? fail!("Could not log in") : success!(u)
  end
end

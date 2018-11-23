class Api::V1::UsersController < ApplicationController

	def login
		@user =  User.find_for_authentication(email: params[:user][:email])
		if @user && @user.valid_password?(params[:user][:password]) && @user.supplier.present? && (@user.supplier.user.email == params[:user][:supplier_email])
			key = ApiKey.create(user_id: @user.id, supplier_email: params[:user][:supplier_email])
      render json: { token: key.access_token }, status: "201"
		else
			render json: { message: "Please check email and password and supplier email" }, status: "401"
		end
	end

	def verify_token
		token = ApiKey.find_by(access_token: params[:token])
    if token && !token.expired?
      render json: { message: "valid token" }, status: "200"
    else
    	render json: { message: "token experied" }, status: "401"
    end
	end

	def get_user
		api_key = ApiKey.find_by(access_token: params[:token])
		if api_key
			render json: { user: api_key.user, profile_picture: api_key.user.profile_picture_url }, status: "200"
		else
			render json: { message: "Not a valid user"}, status: "404"
		end
	end


	private

	def user_params
    params.require(:user).permit(:first_name, :last_name, :mobile, :email)
  end
end

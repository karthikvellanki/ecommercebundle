class Api::V1::ApiController < ApplicationController
	before_action :authenticate
	
	respond_to :json

	def authenticate
		unless current_user
			render json: { message: "Unauthorized. Invalid or expired token" }, status: "401"
	  end
  end

  def current_user
    if params[:token]
      token = ApiKey.find_by(access_token: params[:token])
	    if token.present? && !token.expired?
	      @current_user = User.find(token.user_id)
	    end
	  end
  end

  def current_supplier
  	if params[:token]
  		supplier_email = ApiKey.find_by(access_token: params[:token]).supplier_email
  		@supplier = Provider.find_by(email: supplier_email)
  	end	
  end
end
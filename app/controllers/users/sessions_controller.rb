class Users::SessionsController < Devise::SessionsController

  def create
    # if params[:user][:provider_id].blank?
    #   params[:user][:provider_id] = nil
    # end
    super
  end

end

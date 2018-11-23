class Users::RegistrationsController < Devise::RegistrationsController
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    is_supplier = params[:user][:is_supplier]
    @user = User.new(sign_up_params)
    if sign_up_params["first_name"].present? && sign_up_params["first_name"].split(' ', 2).count == 2
      @user.first_name = sign_up_params["first_name"].split(' ', 2).first
      @user.last_name = sign_up_params["first_name"].split(' ', 2).last
    end

    if @current_supplier.present?
      @user.provider_id = @current_supplier.id
      @user.store_name = @current_supplier.slug
    else
      @user.store_name = "bundle"
    end
    if @user.save
      if is_supplier.to_s == "true"
        @provider = Provider.create(name: @user.company, user:@user, email: @user.email)
      end
      sign_in(:user, @user)
      ApplicationMailer.user_welcome_email(current_user).deliver_later

      if params["user"]["request_quote"].present?
        CreateUserRequestJob.perform_later(params["user"]["request_quote"], @user.id)
      end
      #redirect_to root_path
      if is_supplier.to_s == "true"
        redirect_to profile_admin_users_path
      else
        redirect_to profile_dashboard_users_path
      end
    else
      respond_to do |format|
        flash[:message] =  @user.errors.full_messages.present? ? @user.errors.full_messages.first : "Error creating user"
        format.html { render 'devise/registrations/new', notice: @user.errors.full_messages.present? ? @user.errors.full_messages.first : "Error creating user"}
        format.json { render json: @user.errors, status: :unprocessable_entity, notice: @user.errors.full_messages.present? ? @user.errors.full_messages.first : "Error creating user"  }
      end
    end
  end

  # GET /resource/edit
  # def edit
  # end

  # PUT /resource
  def update
    session[:tab] = nil
    session[:tab] = params[:user][:tab]
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      redirect_to :back, notice: 'Password successfully updated'
    else
      clean_up_passwords resource
      set_minimum_password_length
      redirect_to :back, notice: 'Password not successfully updated. Please re-enter your current password and new password.'
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

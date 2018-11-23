class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :set_session_variables, :check_supplier
  before_action :check_supplier
  include ActionController::Serialization

  def require_admin
    redirect_to root_path unless current_user.admin
  end

  def require_admin_or_provider
    redirect_to root_path unless current_user.admin or current_user.is_provider
  end

  def user_profile
    unless params[:id].to_i == current_user.id || current_user.admin
      redirect_to root_path
    end
  end

  def set_session_variables
    if !session[:cart_id].blank? && Cart.find_by(id: session[:cart_id]).present? && Cart.find_by(id: session[:cart_id]).active
      @cart = session[:cart_id]
    else
      @cart = nil
    end
  end

  def after_sign_in_path_for(resource)
  	if session[:cart].present?
	  	supplier = @current_supplier if @current_supplier.present?

	  	if supplier.present?
	      @cart = Cart.where(user: current_user,provider_id: supplier.id).first_or_create
	    else
	      @cart = Cart.where(user: current_user,provider: nil).first_or_create
	    end

	    session[:cart].each do |cart|
	    	product = Product.find(cart["product_id"])
	    	price_cents = product.price_cents
	    	provider = product.provider.id
	    	CartItem.create!(cart_id: @cart.id, product_id: cart["product_id"],quantity: cart["quantity"],price_cents: price_cents,provider_id: provider)
	    end
	    session[:cart] = nil
	  end

    sign_in_url = new_user_session_url
    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end

  def check_supplier
    sub_domain_slug = request.subdomain
    str = request.domain
    puts "+++++++++++++++++++++++  ----- sub domain #{sub_domain_slug}  -----    ++++++++++++++++++++++"
    puts "+++++++++++++++++++++++  -----  middle  -----    ++++++++++++++++++++++"
    puts "+++++++++++++++++++++++  ----- str  #{str}  -----    ++++++++++++++++++++++"
    puts "++++++++++++++++++++++  -----  #{str.index('.')} ------    +++++++++++++++++"
    if Rails.env.development? || str.index('.')
      puts "step 1"
      if Rails.env.development?
        domain = nil
      else
        domain = str.slice(0..(str.index('.') - 1))
      end
      if domain.present? && Provider.where(slug: domain).present?
        puts "step 2"
        redirect_to '/categories' if request.path.length <= 1
        @current_supplier = Provider.find_by(slug: domain)
      else
        puts "step 3"
        domain = nil
        path_slug = request.path.split('/')[1]
        if sub_domain_slug.present? && Provider.where(slug: sub_domain_slug).present?
          puts "step 4"
          @current_supplier = Provider.find_by(slug: sub_domain_slug)
          if sub_domain_slug == path_slug || request.path.length <= 1
            puts "step 5"
            if Rails.env.development?
              redirect_to "http://#{sub_domain_slug}.orderbundle.localhost:3000/categories"
            else
              redirect_to "https://#{sub_domain_slug}.#{request.domain}/categories"
            end
          elsif path_slug.present? && Provider.where(slug: path_slug).present?
            @current_supplier = Provider.find_by(slug: path_slug)
            if Rails.env.development?
              redirect_to "http://#{path_slug}.orderbundle.localhost:3000/categories"
            else
              redirect_to "https://#{path_slug}.#{request.domain}/categories"
            end
          end
        elsif path_slug.present? && Provider.where(slug: path_slug).present?
          @current_supplier = Provider.find_by(slug: path_slug)
          if Rails.env.development?
            redirect_to "http://#{path_slug}.orderbundle.localhost:3000"
          else
            redirect_to "https://#{path_slug}.#{request.domain}"
          end
        else
          @current_supplier = nil
        end
      end
    else
      puts " ++++++++++++++++++ out of condition  ++++++++++++++++++"
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :location, :mobile, :company, :provider_id, :store_name])
  end
end

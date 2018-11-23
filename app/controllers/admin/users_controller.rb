class Admin::UsersController < ApplicationController
	before_action :authenticate_user!
  before_action :require_admin_or_provider
  skip_before_action :verify_authenticity_token
	layout 'sidenav'


	def index
    if current_user.is_provider
			@users = current_user.provider.customers
		  # @users = User.joins(:user_provider_mappings).where(user_provider_mappings: {provider_id:current_user.provider.id})
    else
      @users = User.all
    end

    @users = @users.search(params[:search]).latest_created_at
    @users = @users.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      if params.has_key?(:template)
          if params[:template] == 'false'
              format.html {render partial: 'table.html', locals: {users: @users}}
          else
              format.html
          end
      else
          format.html
      end
      format.html
      format.json {render json: @users}
    end
  end

  def profile
    @user = current_user
    render 'users/profile'
  end

  def update
    respond_to do |format|
      @user = current_user
      if @user.update(user_params)
        format.html { redirect_to :back, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def catalog
    @user = User.find params[:id]
    @products = current_user.provider.products.old_search(params[:search]).paginate(:page => params[:page], :per_page => 10)
    Inventory.where(user:@user,product: @products).each do |inventory|
      product = @products.find {|p| p == inventory.product}
      product.discount = inventory.discount
    end
    @user_product_ids = (@products & Inventory.where(user: @user).map{|i| i.product}).map{|p| p.id}
    respond_to do |format|
      if params.has_key?(:template)
          if params[:template] == 'false'
              format.html {render partial: 'catalog_table.html', locals: {products: @products}}
          else
              format.html
          end
      else
          format.html
      end
      format.html
      format.json {render json: @products}
    end
  end

  def post_catalog
    @user = User.find params[:id]
    if not params[:product_ids].nil?
      params[:product_ids].each do |product_id|
        @product = Product.find product_id
        @inventory = Inventory.where(user: @user,product:@product).first
        if @inventory.nil?
          @inventory = Inventory.create({product:@product,name:@product.name,description:@product.description,barcode:@product.barcode,price:@product.price,user:@user,quantity: 0, capacity: 1000, threshold: 0, is_invoice: @user.is_invoice == true ? true : false})
          if not @product.image_file_name.nil?
            @inventory.picture = Picture.create({picture_file: @product.image})
            @inventory.save
          end
        end
        is_invoice = params["invoice-"+product_id].blank? ? @user.is_invoice == true ? true :false : (params["invoice-"+product_id] == "on")
        if not is_invoice == @inventory.is_invoice
          @inventory.is_invoice = is_invoice
          @inventory.save
        end
discount = params["discount-"+product_id].to_f
        if not discount.nil?  and not discount == @inventory.discount
          @inventory.discount = discount
          @inventory.update_discounted_price
          @inventory.save
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'Product has been succesfully added to user\'s catalog' }
      format.json { render json: @user}
    end
  end

  def create
    password = SecureRandom.uuid
    params[:user][:password] = password
    params[:user][:password_confirmation] = password
    email = user_params[:email]
    @user = User.new(user_params)
    respond_to do |format|
		  if not User.where(email: email).first.nil?
        @user = User.where(email: email).first
        pmm = UserProviderMapping.where(user:@user,provider:current_user.provider).first_or_create
        SupplierMailer.user_connect_email(current_user.provider, @user).deliver_later
        format.html { redirect_to admin_users_url, notice: 'User exists and is added to your list.' }
        format.json { render json: @user}
      elsif @user.save
        pmm = UserProviderMapping.where(user:@user,provider:current_user.provider).first_or_create
        SupplierMailer.invite_user_email(current_user.provider,@user).deliver_later
        format.html { redirect_to admin_users_url, notice: 'User was successfully invited and added to your list.' }
        format.json { render json: @user}
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_invoice_status
    user = User.find params[:id]
    user.update(is_invoice: user.is_invoice == false ? true : false)
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :location,  :email, :password, :password_confirmation, :company, :mobile, :avatar, :store_name, provider_attributes: [:id, :slug_name, :slug])
    end
end

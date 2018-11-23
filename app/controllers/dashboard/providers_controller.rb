class Dashboard::ProvidersController < ProvidersController
  before_action :set_provider, only: [:show, :edit, :update, :destroy, :inventories]
  before_action :authenticate_user!
  layout 'dashboard_sidenav'
	
  def index
    @providers = UserProviderMapping.where(user: current_user).map{|c| c.provider}
  end

  def new
    @provider = Provider.new
  end

  def create
    create_params = provider_params
    @provider = Provider.where(email: create_params[:email]).first
    
    respond_to do |format|
      if @provider.nil?
        @provider = Provider.new(create_params)
        @provider.save
        create_params[:first_name] = create_params[:name]
        create_params.delete :name
        provider_user = User.new(create_params)
        provider_user.provider = @provider
        provider_user.save(validate: false)
        SupplierMailer.welcome_email(provider_user,current_user).deliver_later
        msg = 'Supplier was successfully created and added to your account.'
      else
        SupplierMailer.client_connect_email(@provider.user,current_user).deliver_later
        msg = 'Supplier already exists and has been added to your account.'
      end
      if @provider.save
        pmm = UserProviderMapping.where(user:current_user,provider:@provider).first_or_create
        format.html { redirect_to dashboard_provider_path(@provider), notice: msg }
        format.json { render json: @provider}
      else
        format.html { render :new }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @inventories = Inventory.where(user: current_user).includes(:product).where(products: {provider_id:@provider.id})
    @providers = UserProviderMapping.where(user: current_user).map{|c| c.provider}
    render "dashboard/inventories/index" and return
    #@products = @provider.products  
    #@products = @products.paginate(:page => params[:page], :per_page => 50)
  end
	
  # GET /credentials/
  def credentials
    @user = current_user
    @providers = Provider.where(user: nil)
    @providers.each do |p|
      pc = ProviderCredential.where(user: @user,provider: p).first
      p.credential = pc ? pc.as_json(except: [:password]) : nil
    end
  end

  def set_credentials
    user = current_user
    provider = Provider.friendly.find params[:provider_id]
    username = params[:username]
    password = params[:password]
    puts username,password
    @pc = ProviderCredential.where(user: user,provider: provider).first
    if @pc
      @pc.username = params[:username]
      @pc.password = params[:password]
    else
      @pc = ProviderCredential.new
      @pc.username = params[:username]
      @pc.password = params[:password]
      @pc.user = user
      @pc.provider = provider
    end
    valid = provider.validate_credentials(username,password)
    if not valid
      render json: {"error":"Invalid credentials"}, status: :unprocessable_entity and return 
    end
    if @pc.save
      render json: {} and return
    else
      render json: @pc.errors, status: :unprocessable_entity and return
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy_credentials
    user = current_user
    provider = Provider.friendly.find params[:provider_id]
    @pc = ProviderCredential.where(user: user,provider: provider).first
    @pc.destroy
    render json: {} and return
  end
  
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def provider_params
      params.require(:provider).permit(:name,:email)
    end

    def set_provider
      @provider = Provider.friendly.find(params[:id])
    end
end

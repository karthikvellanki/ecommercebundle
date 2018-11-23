class Admin::ProvidersController < ProvidersController
  before_action :set_provider, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :require_admin_or_provider, only: [:profile, :update]
  before_action :require_admin, except: [:profile, :update]
  layout 'sidenav'

  # GET /providers
  # GET /providers.json
  def index
    @providers = Provider.all
  end

  # GET /providers/1
  # GET /providers/1.json
  def show
  end

  # GET /providers/new
  def new
    @provider = Provider.new
  end
  
  # GET /providers/profile
  def profile
    if current_user.is_provider
      @provider = current_user.provider
      render :edit
    end
  end

  # GET /providers/1/edit
  def edit
  end

  # POST /providers
  # POST /providers.json
  def create
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to admin_provider_path(@provider), notice: 'Provider was successfully created.' }
        format.json { render :show, status: :created, location: @provider }
      else
        format.html { render :new }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /providers/1
  # PATCH/PUT /providers/1.json
  def update
    respond_to do |format|
      if current_user.is_provider and current_user.provider != @provider
        format.html { redirect_to :back, notice: 'Don\'t try to mess with the system' } and return
      end
      if @provider.update(provider_params)
        provider_user = @provider.user
        provider_user.company = @provider.name
        provider_user.save
        format.html { redirect_to :back, notice: 'Provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @provider }
      else
        format.html { render :edit }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /providers/1
  # DELETE /providers/1.json
  def destroy
    return
    @provider.destroy
    respond_to do |format|
      format.html { redirect_to admin_providers_path, notice: 'Provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider
      @provider = Provider.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def provider_params
      params.require(:provider).permit(:name, :description, :image, :user_id, :ns1, :ns2, :ns3, :ns4, :domain_name)
    end
end

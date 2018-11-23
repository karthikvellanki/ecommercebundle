class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index,:show, :get_product_details]
  layout "stores"
  require 'csv'

  # GET /products
  # GET /products.json
  def index
    if @current_supplier.present?
      @products = @current_supplier.products
    else
      @products = Product.all
    end
    if not params[:q].blank?
      if !@current_supplier.blank?
        @products = @current_supplier.products.search(params[:q],
                              hitsPerPage: 24,
                              page: params[:page],
                              tagFilters: "storefront",
                            )
      else
        @products = @products.search(params[:q],
                              hitsPerPage: 24,
                              page: params[:page],
                              tagFilters: "storefront",
                            )
      end
    else
      if not params[:product_type_filter].blank?
        @products = @products.product_type_filter(params[:product_type_filter])
      else
        @products = @products.order("created_at")
      end
      @products = @products.store_front_products.paginate(:page => params[:page], :per_page => 24)
    end
    @categories = Category.all
    @banners = Banner.all
    if @current_supplier.present?
      id = @current_supplier.id
      @categories = Category.joins(products: :provider).where(providers: {id: id}).uniq
    else
      @categories = Category.all
    end
    if request.url.include? "stores/products"
      render layout: "stores"
    elsif request.path.start_with?('/products')
      render layout: "stores"
    else
      render layout: "stores"
    end
  end
  def get_product_details
  	if @current_supplier.present?
      @products = @current_supplier.products
    else
      @products = Product.all
    end
  	@products =  @products.product_filter(params[:category_id])
  	render partial: 'products/product', locals: {products: @products}
  end
  def live_search
    @products = Product.all.old_search(params[:q])
    render layout: false
  end

  def price_comparison
    @product = Product.find(params[:id])
    user = current_user

    user_credentials = ProviderCredential.where(user: user)
    user_providers = user_credentials.map {|pc| pc.provider}
    without_login_providers = Provider.where(login_required: false)
    providers = user_providers | without_login_providers
    providers_with_pid = ProviderMidMapping.where(product: @product).map {|pmm| pmm.provider}
    providers = providers & providers_with_pid

    completed_results = ScrapResult.where(user: user,product: @product,status: "completed").select { |result| (result.updated_at + result.provider.expiry_seconds) > Time.now }
    ongoing_results = ScrapResult.where(user: user,product: @product,status: "ongoing").select { |result| (result.updated_at + result.provider.expiry_seconds) > Time.now }
    recently_failed_results = ScrapResult.where(user: user,product: @product,status: "failed").select { |result| (result.updated_at + 30) > Time.now }
    completed_providers = completed_results.map {|result| result.provider}
    ongoing_providers = ongoing_results.map {|result| result.provider}
    failed_providers = recently_failed_results.map {|result| result.provider}
    providers = providers - (completed_providers | ongoing_providers | failed_providers)
    @results = completed_results
    providers.each do |provider|
      result = ScrapResult.where(user: user,product: @product,provider: provider).first_or_create
      result.status = "ongoing"
      result.save
      Provider.delay(:retry => false).fetch_delayed(@product.id,user.id,provider.id)
    end
    @complete = !(providers.count > 0 or ongoing_providers.count > 0)
    manual_pmms = ProviderMidMapping.where(product: @product).select {|pmm| pmm.provider.is_manual?}
    manual_pmms.each do |pmm|
      provider = pmm.provider
      price = pmm.price
      result = ScrapResult.new
      result.provider = provider
      result.result = [provider.as_json,true,price,"In Stock",nil,""]
      @results.push result
    end
    product_html = render_to_string(layout: false)
    render json: {"html":product_html,"complete":@complete} and return
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @home_page = true
    @products = Product.all
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:name, :description, :barcode_value1, :barcode_value2)
  end
end

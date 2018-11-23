class Admin::ProductsController < ProductsController
  before_action :authenticate_user!
  before_action :require_admin_or_provider
  before_action :set_product, only: [:show, :edit, :update, :destroy, :upload_product_image, :change_storefront_option]
  layout 'sidenav'

  # GET /products
  # GET /products.json
  def index
  	if current_user.is_provider
		  @products = current_user.provider.products
    else
      @products = Product.all
    end
    if not params[:q].blank?
      @products = @products.old_search(params[:q])
    end
    if not params[:search].blank?
      @products = @products.old_search(params[:search])
    end
    @products = @products.product_type_filter(params[:product_type_filter]).store_front_filter(params[:store_option_type])
    @products = @products.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      if params.key?(:template)
        if params[:template] == 'false'
          format.html { render partial: 'table.html', locals: { products: @products } }
        else
          format.html
        end
      else
        format.html
      end
      format.html
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
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
    if current_user.is_provider
      @product.provider = current_user.provider
    end
    @product.user = @product.provider.user
    respond_to do |format|
      if @product.save
        if params.key?(:pictures) && params[:pictures].present?
          params[:pictures].each do |picture_file|
            @product.pictures.create(picture_file: picture_file)
          end
        end
        format.html { redirect_to admin_product_path(@product), notice: 'Product was successfully created.' }
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
        Inventory.where(product: @product).each do |inventory|
          inventory.update_discounted_price
          inventory.save
        end
        if params.key?(:pictures) && params[:pictures].present?
          params[:pictures].each do |picture_file|
            @product.pictures.create(picture_file: picture_file)
          end
        end
        format.html { redirect_to admin_product_path(@product), notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_product_image
    if params["image-upload-#{@product.id}"].present?
      @product.update(image: params["image-upload-#{@product.id}"])
      redirect_to admin_products_path
    end
  end

  def csv_import
	  file_data = params[:file].read
	  csv_rows  = CSV.parse(file_data)
	  csv_rows.each do |row|
	  	category = Category.find_by(name: row[4])
	  	supplier_category = SupplierCategory.find_by(provider_id: current_user.provider.id, name: row[4].split('/').last)

	  	product_specification = Hash.new
	  	(11..40).each do |k|
	  		next if k.even?
	  		product_specification["#{row[k]}"]  = row[k + 1] if row[k].present? && row[k + 1].present?
        k += 2
	  	end
      begin
        product = Product.new(name: row[0], sku: row[1], price: row[2], description: row[3], category_id:  category.present? ? category.id : nil, supplier_category_id:  supplier_category.present? ? supplier_category.id : nil, brand: row[5], unit: row[6], image: row[7].present? ? URI.parse(row[7]).open : nil, image_file_name: row[7].present? ? row[7].split('/').last : nil, inventory_count: row[8], inventory_policy: row[9], barcode_value: row[10], technical_specifications: product_specification, barcode_value1: row[41],barcode_value2: row[42])
      rescue => e
        product = Product.new(name: row[0], sku: row[1], price: row[2], description: row[3], category_id:  category.present? ? category.id : nil, supplier_category_id:  supplier_category.present? ? supplier_category.id : nil, brand: row[5], unit: row[6], inventory_count: row[8], inventory_policy: row[9], barcode_value: row[10], technical_specifications: product_specification, barcode_value1: row[41],barcode_value2: row[42])
      end
      if current_user.is_provider
        product.provider = current_user.provider
      end
      product.save
	  end

	  respond_to do |format|
	    format.html { redirect_to admin_products_path, :notice => "Successfully imported the CSV file." }
	  end
	end


  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    Inventory.where(product: @product).delete_all
    @product.destroy
    respond_to do |format|
      format.html { redirect_to admin_products_path, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  def destroy_multiple
    products = Product.where(id: params[:product_ids].split(","))
    products.destroy_all

    respond_to do |format|
      format.html { redirect_to admin_products_path, notice: 'Product Deleted' }
      format.json { head :no_content}
    end
  end

  def products_for_supplier
    params["all_data"].each do |x|
      if params["all_data"][x][0].present?
        category = Category.find_by(name: params["all_data"][x][3])
        supplier_category = SupplierCategory.find_by(name: params["all_data"][x][4].split('/').last)
        product_specification = Hash.new
        (6..35).each do |num|
          product_specification["#{params["all_data"][x][num].split(':').first}"] = params["all_data"][x][num].split(':').last if params["all_data"][x][num].present?
        end
        begin
        product = Product.new(name: params["all_data"][x][0],sku: params["all_data"][x][1], price: params["all_data"][x][2], category_id: category.present? ? category.id : nil, supplier_category_id: supplier_category.present? ? supplier_category.id : nil, image: params["all_data"][x][5].present? ? URI.parse(params["all_data"][x][5]).open : nil, image_file_name: params["all_data"][x][5].present? ? params["all_data"][x][5].split('/').last : nil, brand: params["all_data"][x][6],technical_specifications: product_specification)
        rescue => e
        product = Product.new(name: params["all_data"][x][0],sku: params["all_data"][x][1], price: params["all_data"][x][2], category_id: category.present? ? category.id : nil, supplier_category_id: supplier_category.present? ? supplier_category.id : nil,brand: params["all_data"][x][6],technical_specifications: product_specification)
        end
        if current_user.is_provider
          product.provider = current_user.provider
        end
        product.save
      end
    end
  end

  def change_storefront_option
    @product.update(storefront_option: @product.storefront_option ? false : true)
    render partial: 'admin/products/product_table_partial', locals: {product: @product}
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
    if not current_user.admin and not @product.provider != current_user.provider
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:delivery_time, :name, :sku, :price_cents, :short_description, :picturable, :barcode, :price, :is_aggregatable, :description, :image, :category_id, :supplier_category_id, :storefront_option, :unit, :amazon_id, :sku, :brand, :image, :inventory_count, :inventory_policy, :barcode_value, :barcode_value1, :barcode_value2, aggregation_rounds_attributes: [:id, :start_date, :end_date, :qty_limit, :_destroy])
  end
end

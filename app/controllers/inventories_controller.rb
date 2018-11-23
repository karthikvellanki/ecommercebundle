class InventoriesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_inventory_and_authorize_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout 'dashboard_sidenav'

  # GET /inventories
  # GET /inventories.json
  def index
    @inventories = Inventory.where(user: current_user)
    if not params[:q].blank?
      @inventories = @inventories.search(params[:q])
    end
    if not params[:template].blank? and params[:template] == 'false'
      render partial: 'table.html', locals: { inventories: @inventories} and return
    end
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
  end

  def import
    product = Product.where(id:  params[:product_id]).first
    inventory = Inventory.where(user: current_user,product:product).first
    respond_to do |format|
	    format.json do
        if product.nil?
          render json: {"error":"No such product exists"}, :status => 404 and return
        end
        if not inventory.nil?
          render json: {"error":"Inventory already exists for given product"}, :status => 400 and return
        else
          @inventory = Inventory.create({product:product,name:product.name,description:product.description,barcode:product.barcode,user:current_user,quantity: 0, capacity: 1000, threshold: 0})
          if not product.category.nil?
            collection = Collection.where(user:current_user,category:product.category).first
            if collection.nil?
              cat = product.category
              collection = Collection.create({category:cat,name:cat.name,description: cat.description,user:current_user})
              if cat.image.exists?
                collection.picture = Picture.create({picture_file: cat.image})
                collection.save
              end
            end
            CollectionInventory.new({collection:collection,inventory:@inventory}).save
          end
          if not product.image_file_name.nil?
            @inventory.picture = Picture.create({picture_file: product.image})
            @inventory.save
          end
          render json: @inventory and return
        end
      end
    end
  end

  def byBarcode
    barcode = params[:barcode]
    #product = Product.where(barcode: barcode).first
    #if product.nil?
    #  render json: {"error":"Product with given barcode does not exist"}, :status => 404 and return
    #end
    inventory = Inventory.where(user: current_user,barcode: barcode).first
    respond_to do |format|
	    format.json do
        if inventory.nil?
          render json: {"error":"No inventory for given barcode. Please create one first"}, :status => 404
        else
		  if request.put?
            quantity = params[:data][:quantity].to_i
            inventory.quantity = quantity
            inventory.save
          end
          render json: inventory
        end
      end
    end
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
    @inventory.build_picture
    @collections = Collection.where(user: current_user)
    @providers = UserProviderMapping.where(user: current_user).map{|c| c.provider}
  end

  # GET /inventories/1/edit
  def edit
    if not @inventory.picture.present?
      @inventory.build_picture
    end
    @collections = Collection.where(user: current_user)
    @providers = UserProviderMapping.where(user: current_user).map{|c| c.provider}
  end

  # POST /inventories
  # POST /inventories.json
  def create
    create_params = inventory_params
    create_params[:user_id] = current_user.id
    product_params = create_params.clone
    product_params.delete :quantity
    product_params.delete :threshold
    product_params.delete :capacity
    @product = Product.new(product_params)
    @inventory = Inventory.new(create_params)
    respond_to do |format|
      if params[:provider_id].blank?
        format.html { render :new, notice: "Supplier must be provided" }
        format.json { render json: {}, status: :unprocessable_entity }
      elsif @product.save
        provider = Provider.friendly.find params[:provider_id]
        @product.user = current_user
        @product.provider = provider
        # @product.storefront_option = false
        @product.save
        @inventory.product = @product
        @inventory.save
        begin
          collection = Collection.find params[:collection_id]
          CollectionInventory.new({collection:collection,inventory:@inventory}).save
        rescue ActiveRecord::RecordNotFound => e
          puts e
        end
        format.html { redirect_to "/dashboard/products", notice: 'Product was successfully created.' }
        format.json { render json: @inventory}
      else
        format.html { render :new }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventories/1
  # PATCH/PUT /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
		begin
		  collection = Collection.find params[:collection_id]
		  CollectionInventory.where({inventory:@inventory}).each do |ci|
		    ci.destroy
		  end
		  CollectionInventory.new({collection:collection,inventory:@inventory}).save
		rescue ActiveRecord::RecordNotFound => e
		  puts e
		end
        format.html { redirect_to "/dashboard/products", notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory }
      else
        format.html { render :edit }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventories/1
  # DELETE /inventories/1.json
  def destroy
    CollectionInventory.where(inventory: @inventory).each do |c|
      c.destroy
    end
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url, notice: 'Inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def destroy_multiple
    products = Inventory.where(user: current_user, :id => params[:inventory_ids].split(","))
    products.destroy_all

    respond_to do |format|
      format.html { redirect_to inventories_path, notice: 'Product Deleted' }
      format.json { head :no_content}
    end
  end

  private
    def authorize_user
      if params[:user_id].to_s != current_user.id.to_s
        render json: {"error":"You are not authorized for this action"}, :status => 401 and return
      end
	  # IMPLEMENT INVENTORY OWNERSHIP CHECK
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_and_authorize_user
      @inventory = Inventory.find(params[:id])
	  if @inventory.user != current_user
        render json: {"error":"You are not authorized for this action"}, :status => 401 and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_params
      params.require(:inventory).permit(:id,:name,:price,:price_cents,:description,:sku,:barcode,:picture_id, :user_id,:collection_id,:provider_id,:quantity,:capacity, :unit, :threshold,picture_attributes: [:picture_file])
    end
end

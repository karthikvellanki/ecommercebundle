class CartItemsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_cart_item, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:session_cart_item]

  # GET /cart_items
  # GET /cart_items.json
  def index
    @cart_items = CartItem.all
  end

  # GET /cart_items/1
  # GET /cart_items/1.json
  def show
  end

  # GET /cart_items/new
  def new
    @cart_item = CartItem.new
  end

  # GET /cart_items/1/edit
  def edit
  end

  # POST /cart_items
  # POST /cart_items.json
  def create
    cart = nil
    product = Product.find params[:product_id]
    provider = product.provider
    supplier = @current_supplier if @current_supplier.present?
    inventory = Inventory.where(user: current_user,product: product).first

    if product.is_group_product(current_user.id)
    	price_cents = product.group_products.last.price_cents
    else
	    if inventory.nil?
	      price_cents = product.price_cents
	      inventory = Inventory.create({product: product, name: product.name, sku: product.sku, user: current_user, quantity: 0, capacity: 0, threshold: 0, is_invoice: current_user.is_invoice == true ? true : false})
	      if not product.image_file_name.nil?
	        inventory.picture = Picture.create({picture_file: product.image})
	        inventory.save
	      end
	    else
	      price_cents = inventory.price_cents
	    end
	  end
    if supplier.present?
      cart = Cart.where(user: current_user,provider: supplier.id).first_or_create
    else
      cart = Cart.where(user: current_user,provider: nil).first_or_create
    end
    quantity = params[:quantity].to_i
    CartItem.update_cart(cart, product.id,quantity,price_cents,provider,true)
    render partial: "carts/carts_partial"
    # if cart
    #   respond_to do |format|
    #     format.html { redirect_to "/carts/" }
    #     format.json { render json: cart.id.to_s, status: :created }
    #   end
    # else
    #   respond_to do |format|
    #     format.html { render :new }
    #     format.json { render json: 'error', status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /cart_items/1
  # PATCH/PUT /cart_items/1.json
  def update
    respond_to do |format|
      if @cart_item.update(cart_item_params)
        if @cart_item.quantity <= 0
          @cart_item.destroy
          format.html { redirect_to :index, notice: 'Cart item deleted successfully' }
          format.json { render :index, status: :ok}
        else
          format.html { redirect_to @cart_item, notice: '' }
          format.json { render :show, status: :ok, location: @cart_item }
        end
      else
        format.html { render :edit }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def session_cart_item
  	product = Hash.new
  	product['product_id'] = params[:product_id]
  	product['quantity'] = params[:quantity]
  	(session[:cart] ||= []) << product
		render partial: 'carts/carts_count'
  end


  # DELETE /cart_items/1
  # DELETE /cart_items/1.json
  def destroy
    @cart_item.destroy
    respond_to do |format|
      format.html { redirect_to cart_items_url, notice: '' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cart_item
    @cart_item = CartItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cart_item_params
    params.require(:cart_item).permit(:cart_id, :product_id, :quantity)
  end
end

class CartsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_cart, only: [:show, :edit, :update, :destroy, :get_cart_items, :get_small_cart, :checkout, :pay]
  before_action :authenticate_user!
  layout 'dashboard_sidenav'

  def show
    if @current_supplier.present?
      supplier_id = @current_supplier.id
    else
      supplier_id = nil
    end
    if @cart.active || @cart.provider_id == supplier_id
        if params[:type] == 'dropdown'
            respond_to do |format|
              format.json { render partial: 'cart_items/cart_dropdown.html', status: :ok}
              format.html{}
            end
        else
            respond_to do |format|
                format.json { render partial: 'cart_items/cart_items.html', status: :ok}
                format.html{}
            end
        end
    else
        redirect_to :root
    end
  end

  def index
    if @current_supplier.present?
      supplier = @current_supplier
      @cart = Cart.where(user: current_user, provider_id: supplier.id).last
    else
      @cart = Cart.where(user: current_user, provider_id: nil).last
    end
  end

  # GET /carts/new
  def new
    @cart = Cart.new
  end

  # GET /carts/1/edit
  def edit
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    respond_to do |format|
      if @cart.update(cart_params)
        @cart.cart_items.each do |item|
		      if item.quantity == 0
            item.destroy
          end
        end
        format.html { redirect_to action: "index", notice: 'Cart was successfully updated.' }
        format.json { render :show, status: :ok, location: @cart }
      else
        format.html { render :edit }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  def checkout
    if @cart.user != current_user
      render json: {"error":"You are not authorized for this action"}, :status => 401 and return
    end
    if not @cart.provider.nil?
      @order = Order.new
      @order.first_name = current_user.first_name
      @order.last_name = current_user.last_name
      @order.mobile_number = current_user.mobile
      @order.email = current_user.email
      @order.user = current_user
      @order.total_price_cents = 0
      @order.order_date = DateTime.now
      @cart.cart_items.each do |cart_item|
        @order.total_price_cents += cart_item.price_cents * cart_item.quantity
        order_item = @order.order_items.new(price_cents: cart_item.price_cents, product: cart_item.product, quantity: cart_item.quantity,provider: cart_item.provider)
        cart_item.destroy
      end
      respond_to do |format|
        if @order.save
          format.html { redirect_to @order,  notice: 'Order was successfully created.' }
          format.json { render json:  @order, status: :ok}
        else
          format.html { render :new }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to carts_url, notice: 'Cart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_cart_items
    respond_to do |format|
      format.json {render partial: 'cart_items/cart_items.html', status: :ok}
      format.html {}
    end
  end

  def get_small_cart
    respond_to do |format|
      format.json {render partial: 'carts/cart_small.html'}
      format.html {}
    end
  end

  # Make a one-off payment to the user.
  # See app/assets/javascripts/app/pay.coffee

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = Cart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_params
      params.require(:cart).permit(:id,:active,:cart_items_attributes => [:id,:quantity])
    end
end

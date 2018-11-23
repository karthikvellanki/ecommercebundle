class Admin::OrdersController < OrdersController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :fulfilled]
  before_action :authenticate_user!
  before_action :require_admin_or_provider
  layout 'sidenav'

  # GET /orders
  # GET /orders.json
  def index
  	if current_user.is_provider
		  @orders = Order.latest_created_first.joins(:order_items).where(order_items: {provider_id:current_user.provider.id}).distinct
    else
      @orders = Order.all
    end
    @orders = @orders.date_filter(params[:start_date], params[:end_date]).search(params[:search]).page(params[:page])
    respond_to do |format|
      if params.has_key?(:template)
        if params[:template] == 'false'
          format.html {render partial: 'table.html', locals: {orders: @orders}}
        else
          format.html
        end
      else
        format.html
      end
      format.html
      format.json {render json: @orders}
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_order_path(@order), notice: 'order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render notice: 'Error in processing your order'}
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to admin_order_path(@order), notice: 'order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to admin_orders_path, notice: 'order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def invoices
    if current_user.is_provider
      @orders = Order.where(status: [:fulfilled,:paid]).latest_created_first.joins(:order_items).where(order_items: {provider_id:current_user.provider.id}).distinct
    else
      @orders = Order.where(status: [:fulfilled,:paid])
    end
    render 'invoices/invoices.html',locals: {orders: @orders}   
  end

  def fulfilled 
    respond_to do |format|
      if @order.update(order_params)
        @order.recalcuate_order_total
        @order.update_to_fulfilled
        UserMailer.order_email(@order).deliver_later
        format.html { redirect_to admin_order_path(@order), notice: 'Invoice generated successfully' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :index }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:user_id, :email, :first_name, :last_name, :mobile_number, :status, :total_price_cents, :sales_tax, :other_charges_name, :other_charges, :shipping_charges, :order_date, order_items_attributes: [:id, :status])
    end
end

class OrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_order_and_authorize, only: [:show, :pay, :edit, :update, :destroy, :order_success, :pay_with_card, :payments, :stripe_pay]
  layout 'dashboard_sidenav'

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.where(user: current_user).latest_created_first
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @cart
    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePdf.new(@order, view_context)
        send_data pdf.render, filename: "order_#{@order.id}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  def pay_with_card
    token = params[:stripeToken]
    begin
        sub = Subscription.find_by(user_id: current_user.id, stripe_customer_token: token)
        if sub.nil?
          last4 = params[:last4]
          exp_year = params[:exp_year]
          exp_month = params[:exp_month]
          subscription = Subscription.new(stripe_customer_token: token, user_id: current_user.id,last4: last4,exp_year: exp_year,exp_month: exp_month)
          new_sub = Order.save_with_payment(current_user.email,token,@order.id,@order.total_price_cents)
          subscription.stripe_user_id = new_sub
          subscription.save
        else
          Order.payment_only(@order.id,@order.total_price_cents,sub.stripe_user_id)
        end
    rescue => e
      puts "Payment failed"
      puts e
      ExceptionNotifier.notify_exception e
      render json: {"error":"Payment was unsuccessful"}, status: :unprocessable_entity and return
    end
    @order.status = :paid
    @order.save
    render json: {}, status: 200
  end


  def pay
    account = current_user.bank_accounts.first
    if account.nil?
      render json: {}, status: 400
    else
      if current_user.customer_id.nil?
        account.stripe_user_id = Order.save_with_payment(current_user.email,account.stripe_customer_token,@order.id,@order.total_price_cents.to_i)
        account.save
        @order.status = :paid
        @order.save
        render json: {}, status: 200
      else
        begin
          Order.payment_only(@order.id,@order.total_price_cents.to_i,current_user.customer_id)
          @order.status = :paid
          @order.save
          render json: {}, status: 200
        rescue => e
          render :json => { :error_message => e.message }, :status => :unprocessable_entity
        end
      end
    end
  end

  def invoices
    @orders = Order.where(status: [:fulfilled,:paid], user: current_user).latest_created_first
    render 'invoices/invoices.html',locals: {orders: @orders}
  end

  def rating
    @order = Order.find(params[:id])
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  def guest_orders
    @orders = Order.all.where(email: params[:guest_email], mobile_number: params[:guest_mobile_number]).order('created_at DESC')
    respond_to do |format|
      format.html { render 'guest_order_show' }
    end
  end

  def guest_order_show
    @orders
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @cart = Cart.find(params[:cart_id].to_i)
    token = params[:stripeToken]
    #payment old changes
    # if @cart.instant_total_price_cents != 0
    #   begin
    #     puts "Processing payment"
    #     if params[:payment_method].blank? or params[:payment_method] == "card"
    #       sub = Subscription.find_by(user_id: current_user.id, stripe_customer_token: token)
    #       if sub.nil?
    #         last4 = params[:last4]
    #         exp_year = params[:exp_year]
    #         exp_month = params[:exp_month]
    #         subscription = Subscription.new(stripe_customer_token: token, user_id: current_user.id,last4: last4,exp_year: exp_year,exp_month: exp_month)
    #         new_sub = Order.save_with_payment(params[:email],token,current_user.name,@cart.instant_total_price_cents)
    #         subscription.stripe_user_id = new_sub
    #         subscription.save
    #       else
    #         Order.payment_only(current_user.name,@cart.instant_total_price_cents,sub.stripe_user_id)
    #       end
    #     else
    #       account = current_user.bank_accounts.first
    #       if account.stripe_user_id.nil?
    #         account.stripe_user_id = Order.save_with_payment(params[:email],account.stripe_customer_token,current_user.name,@cart.instant_total_price_cents)
    #         account.save
    #       else
    #         Order.payment_only(current_user.name,@cart.instant_total_price_cents,account.stripe_user_id)
    #       end
    #     end
    #   rescue => e
    #     puts "Payment failed"
    #     puts e
    #     ExceptionNotifier.notify_exception e
    #     render json: {"error":"Payment was unsuccessful"}, status: :unprocessable_entity and return
    #   end
    # end

    address_type = params[:address_type].nil? ? "user" : params[:address_type]
    if params[:old_address_id].blank?
      current_user.addresses.create!(first_name: params[:first_name], last_name: params[:last_name], mobile: params[:mobile], line_1: params[:line_1], line_2: params[:line_2], line_3: params[:line_3], city: params[:city], state: params[:state], address_type: address_type, pincode: params[:pincode].to_i, name: "shipping")
    else
      puts "Address found. Updating it"
      address = Address.find params[:old_address_id]
      address.updated_at = DateTime.now
      address.save
    end

    CartItem.where(cart: @cart).group_by(&:provider).each do |provider,cart_items_all|
      cart_items_instant = cart_items_all.select {|ci| ci.product.storefront_option == true}
      cart_items_invoice = cart_items_all.select {|ci| ci.product.storefront_option == false}
      [cart_items_instant,cart_items_invoice].each do |cart_items|
        if cart_items.length > 0
          @order = Order.new
          @order.first_name = params[:first_name]
          @order.last_name = params[:last_name]
          @order.mobile_number = params[:mobile_number]
          @order.email = params[:email]
          @order.order_date = DateTime.now
          @order.total_price_cents = 0
          @order.user = current_user
          @order.save!
          # if cart_items.first.product.storefront_option
          #   @order.status = :unpaid
          #   @order.save!
          # end

          cart_items.each do |cart_item|
            @order.total_price_cents += cart_item.price_cents * cart_item.quantity
            order_item = @order.order_items.new(price_cents: cart_item.price_cents, product: cart_item.product, quantity: cart_item.quantity,provider: cart_item.provider)
            cart_item.destroy
          end

          @order.recalcuate_order_total
          @order.addresses.create!(first_name: params[:first_name], last_name: params[:last_name], mobile: params[:mobile], line_1: params[:line_1], line_2: params[:line_2], line_3: params[:line_3], city: params[:city], state: params[:state], address_type: address_type, pincode: params[:pincode].to_i, name: "shipping")
          SupplierMailer.order_email(@order).deliver_later
        end
      end
    end

    respond_to do |format|
      format.html { render json: @order.id, status: :ok }
      format.json { render json: @order.id, status: :ok}
    end
  end

  def create_with_default_address
    @cart = Cart.find(params[:cart_id].to_i)
    @user = current_user
    @order = Order.new
    respond_to do |format|
      if @user.addresses.first.nil?
        format.html { render :new }
        format.json { render json: {message: "Please add an address to your account first using the website."}, status: :unprocessable_entity }
      else
        @order.first_name = @user.first_name
        if not @user.last_name.nil?
          @order.last_name = @user.last_name
        end
        if not @user.mobile.nil?
          @order.mobile_number = @user.mobile
        end
        @order.email = @user.email
        @order.order_date = DateTime.now
        @order.total_price_cents = 0
        @order.save
        @order.user = current_user
        if params.has_key?(:cart_id)
          @cart.cart_items.each do |cart_item|
            @order.total_price_cents += cart_item.price_cents * cart_item.quantity
            order_item = @order.order_items.new(price_cents: cart_item.price_cents, product: cart_item.product, quantity: cart_item.quantity,provider: cart_item.provider)
            cart_item.destroy
          end
        end
        if @order.save!
          address = @user.addresses.first.dup
          address.save
          @order.addresses << address
          @order.recalcuate_order_total
          SupplierMailer.order_email(@order).deliver_later
          format.html { redirect_to carts_url, notice: 'Order was successfully placed.' }
          format.json { render json: {id: @order.id}, status: :ok}
        else
          format.html { render :new }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def order_item_fields
    respond_to do |format|
      format.json {render partial: 'new_order_order_item_fields', status: :ok}
    end
  end


  def process_payment
    @order = Order.find(params[:id])
    token = params[:stripe_customer_token]
    cart = Cart.find(session[:cart_id])
    user = User.find(params[:user_id])
    sub = Subscription.find_by(user_id: params[:user_id], stripe_customer_token: token)
    flag = 0
    #stripe processing code
    if sub.nil?
      subscription = Subscription.new(stripe_customer_token: token, user_id: params[:user_id] )
      new_sub = Order.save_with_payment(user.email,token,@order.id,@order.total_price_cents)
      subscription.stripe_user_id = new_sub
      flag = 1 if subscription.save!
    else
      Order.payment_only(@order.id,@order.total_price_cents,sub.stripe_user_id)
      flag = 1
    end
    #end stripe processing code

    #email code
    if flag == 1
      cart = Cart.find(session[:cart_id].to_i)
      email_obj = []
      cart.cart_items.each do |cart_item|
        email_obj.push(product_name:cart_item.product.name, quantity: cart_item.quantity, price:cart_item.product.price_cents.to_s+"$")
      end
    end
    #end email code
    respond_to do |format|
      if @order.update(status: 1) && cart.update(active: false) && flag == 1
        OrderConfirmationJob.perform_now(session[:cart_id].to_i,user.id,user.first_name+" "+user.last_name,email_obj)
        session[:cart_id] = nil
        format.html { render 'order_success.html', notice: 'Payment was successfully processed.' }
        format.json { render 'order_success.html', status: :created}
      else
        format.html { render 'order_failure.html', notice: 'Payment Failure.' }
        format.json { render 'order_failure.html', status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end



  def order_success

  end


  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def payments
    redirect_to order_path(@order) if @order.status == "paid"
  end

  def stripe_pay
    # Find the user to pay.
    user = @order.order_items.last.provider.user

    # Charge $10.
    amount = @order.total_price_cents.to_i
    # Calculate the fee amount that goes to the application.
    fee = (amount * Rails.application.secrets.fee_percentage).to_i

    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    begin
      # Create a Charge:
      # charge = Stripe::Charge.create({
      #   :amount => amount,
      #   :currency => user.currency,
      #   :source => params[:token],
      #   # :source => "tok_mastercard_debit_transferSuccess", #replace this with params[:token] from stripe
      #   :transfer_group => "{ORDER_#{@order.id}}"
      # })
      providers = @order.order_items.map(&:provider).uniq
      main_account_fee = 30/providers.count
      providers.each do |provider|
        price_cents = @order.order_items.where(provider_id: provider.id).sum(:price_cents)
        charge = Stripe::Charge.create({
          :amount => price_cents.to_i,
          :currency => provider.user.currency,
          :source => params[:token],
        }, :stripe_account => provider.user.stripe_user_id)
        @order.update(payment_details: charge, status: :paid)
        price_cents = 0
      end

      flash[:notice] = "Charged successfully"
      redirect_to order_path( @order )
    rescue Stripe::CardError => e
      error = e.json_body[:error][:message]
      flash[:error] = "Charge failed! #{error}"
      redirect_to payments_order_path( @order )
    end


  #   begin
  #     charge_attrs = {
  #       amount: amount,
  #       currency: user.currency,
  #       source: "tok_visa",
  #       description: "Bundle via Stripe Connect",
  #       application_fee: fee
  #     }
  #
  #     charge_attrs[:destination] = Rails.application.secrets.stripe_user_id
  #     charge = Stripe::Charge.create( charge_attrs )
  #     @cart.cart_items.each do |ci|
  #       if ci.provider.user.stripe_user_id.present?
  #         transfer = Stripe::Transfer.create({
  #           :amount => ci.price_cents.to_i,
  #           :currency => user.currency,
  #           :destination => ci.provider.user.stripe_user_id,
  #           :transfer_group => "{ORDER_#{@cart.id}}",
  #         })
  #       end
  #     end
  #
  #     # case "platform"
  #     # when 'connected'
  #     #   # Use the user-to-be-paid's access token
  #     #   # to make the charge directly on their account
  #     #   charge = Stripe::Charge.create( charge_attrs, Rails.application.secrets.stripe_secret_key )
  #     #   @cart.cart_items.each do |ci|
  #     #     if @cart_item.provider.user.stripe_user_id.present?
  #     #       transfer = Stripe::Transfer.create({
  #     #         :amount => ci.price_cents.to_i,
  #     #         :currency => @cart_item.provider.user.currency,
  #     #         :destination => @cart_item.provider.user.stripe_user_id,
  #     #         :transfer_group => "{ORDER_#{@cart.id}}",
  #     #       })
  #     #     end
  #     #   end
  #     # when 'platform'
  #     #   # Use the platform's access token, and specify the
  #     #   # connected account's user id as the destination so that
  #     #   # the charge is transferred to their account.
  #     #   charge_attrs[:destination] = Rails.application.secrets.stripe_user_id
  #     #   charge = Stripe::Charge.create( charge_attrs )
  #     #   @cart.cart_items.each do |ci|
  #     #     if ci.provider.user.stripe_user_id.present?
  #     #       transfer = Stripe::Transfer.create({
  #     #         :amount => ci.price_cents.to_i,
  #     #         :currency => user.currency,
  #     #         :destination => ci.provider.user.stripe_user_id,
  #     #         :transfer_group => "{ORDER_#{@cart.id}}",
  #     #       })
  #     #     end
  #     #   end
  #     # end
  #
  #     # flash[:notice] = "Charged successfully! <a target='_blank' rel='#{params[:charge_on]}-account' href='https://dashboard.stripe.com/test/payments/#{charge.id}'>View in dashboard &raquo;</a>"
  #     flash[:notice] = "Charged successfully!"
  #
  #   rescue Stripe::CardError => e
  #     error = e.json_body[:error][:message]
  #     flash[:error] = "Charge failed! #{error}"
  #   end
  #   redirect_to cart_path( @cart )
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order_and_authorize
    @order = Order.find(params[:id])
    if !(current_user.admin or current_user.is_provider) and current_user != @order.user
      render json: {"error":"You are not authorized for this action"}, :status => 401 and return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:user_id, :email, :first_name, :last_name, :mobile_number, :status, :payment_details, :total_price_cents, :stripeToken, :old_address_id)
  end
end

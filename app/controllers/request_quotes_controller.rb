class RequestQuotesController < ApplicationController
  before_action :set_request_quote, only: [:show, :edit, :update, :destroy]
  layout "visitor"

  # GET /request_quotes
  # GET /request_quotes.json
  def index
    @category = Category.all
    @new_user = User.new
    @quote_request = QuoteRequest.new
    render "visitors/request_quotes"
  end

  # GET /request_quotes/1
  # GET /request_quotes/1.json
  def show
  end

  # GET /request_quotes/new
  def new
    @request_quote = RequestQuote.new
  end

  # GET /request_quotes/1/edit
  def edit
  end

  # POST /request_quotes
  # POST /request_quotes.json
  def create
    @request_quote = RequestQuote.new(request_quote_params)
    if params[:request_quote][:signup] == "true"
      user = User.new({email: params[:request_quote][:email], mobile: params[:request_quote][:phone]})
      user.save(validate: false)
      sign_in user
      ApplicationMailer.user_welcome_email(user,true).deliver_later
    end
    @request_quote.user = current_user
    product = @request_quote.product
    respond_to do |format|
      if @request_quote.save
        if not product.nil? and product.storefront_option
          if product.provider and product.provider.user
            SupplierBid.create(supplier_id: product.provider.user.id, request_quote_id: @request_quote.id, price: product.price)
          end
        end
        format.html { redirect_to @request_quote, notice: 'Request for quotes was successfully created.' }
        format.json { render :show, status: :created, location: @request_quote }
      else
        format.html { render :new }
        format.json { render json: @request_quote.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /request_quotes/1
  # PATCH/PUT /request_quotes/1.json
  def update
    respond_to do |format|
      if @request_quote.update(request_quote_params)
        format.html { redirect_to @request_quote, notice: 'Request quote was successfully updated.' }
        format.json { render :show, status: :ok, location: @request_quote }
      else
        format.html { render :edit }
        format.json { render json: @request_quote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_quotes/1
  # DELETE /request_quotes/1.json
  def destroy
    @request_quote.destroy
    respond_to do |format|
      format.html { redirect_to request_quotes_url, notice: 'Request quote was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request_quote
      @request_quote = RequestQuote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_quote_params
      params.require(:request_quote).permit(:product_name, :product_id, :item_number, :description, :quantity)
    end
end

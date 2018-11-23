class Admin::RequestQuotesController < RequestQuotesController
  before_action :set_request_quote, only: [:show, :edit, :update, :destroy, :create_bid]
  before_action :require_admin_or_provider
  before_action :authenticate_user!
  layout 'sidenav'

  # GET /request_quotes
  # GET /request_quotes.json
  def index
    @request_quotes = RequestQuote.joins(:user).where(users: {id: current_user.provider.customers.pluck(:id)})
    if current_user.is_provider
      @products = Product.where(provider: current_user.provider)
    end
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

    respond_to do |format|
      if @request_quote.save
        format.html { redirect_to @request_quote, notice: 'Request quote was successfully created.' }
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

  def create_bid
    @supplier_bid = SupplierBid.find_by(supplier_id: current_user.id, request_quote_id: @request_quote.id,product_id: request_quote_params[:product_id])
    if @supplier_bid.nil?
      SupplierBid.create(supplier_id: current_user.id, request_quote_id: @request_quote.id, product_id: request_quote_params[:product_id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request_quote
      @request_quote = RequestQuote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_quote_params
      params.require(:request_quote).permit(:id, :product_name, :product_id, :item_number, :description, :quantity)
    end
end

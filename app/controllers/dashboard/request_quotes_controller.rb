class Dashboard::RequestQuotesController < RequestQuotesController
  before_action :set_request_quote, only: [:show, :edit, :update, :destroy, :accept_bid]
  before_action :authenticate_user!
  layout 'dashboard_sidenav'
  include ApplicationHelper

  # GET /request_quotes
  # GET /request_quotes.json
  def index
    @request_quotes = current_user.request_quotes.page params[:page]
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

  def accept_bid
    bid = @request_quote.supplier_bids.find params[:bid_id]
    if not bid.nil?
      bid.status = "accepted"
      bid.save
      UserProviderMapping.where(user:current_user,provider:bid.supplier.provider).first_or_create
      SupplierMailer.bid_accepted_email(bid.supplier,current_user,bid).deliver_later
    end
  end

  def create_request_quotes
    params["all_data"].each do |x|
      if params["all_data"][x][0].present?
        RequestQuote.create(product_name: params["all_data"][x][0], item_number: params["all_data"][x][1], description: params["all_data"][x][2], quantity: params["all_data"][x][3], user_id: current_user.id, provider_id: if current_user.provider.present? then current_user.provider.id end)
      end
    end
  end

  # DELETE /request_quotes/1
  # DELETE /request_quotes/1.json
  def destroy
    @request_quote.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_request_quotes_path, notice: 'Request quote was successfully destroyed.' }
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
      params.require(:request_quote).permit(:product_name, :item_number, :bid_id, :description, :quantity, :provider_id)
    end
end

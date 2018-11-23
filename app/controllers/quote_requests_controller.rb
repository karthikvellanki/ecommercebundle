class QuoteRequestsController < ApplicationController
  before_action :set_quote_request, only: [:show, :edit, :update, :destroy]

  # GET /quote_requests
  # GET /quote_requests.json
  def index
    @quote_requests = QuoteRequest.all
  end

  # GET /quote_requests/1
  # GET /quote_requests/1.json
  def show
  end

  # GET /quote_requests/new
  def new
    @quote_request = QuoteRequest.new
  end

  # GET /quote_requests/1/edit
  def edit
  end

  # POST /quote_requests
  # POST /quote_requests.json
  def create
    @quote_request = QuoteRequest.new(quote_request_params)
    respond_to do |format|
      if @quote_request.save
        format.html { redirect_to "/categories", notice: 'Quote request was successfully created.' }
        format.json { render :show, status: :created, location: @quote_request }
      else
        format.html { render :new }
        format.json { render json: @quote_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quote_requests/1
  # PATCH/PUT /quote_requests/1.json
  def update
    respond_to do |format|
      if @quote_request.update(quote_request_params)
        format.html { redirect_to @quote_request, notice: 'Quote request was successfully updated.' }
        format.json { render :show, status: :ok, location: @quote_request }
      else
        format.html { render :edit }
        format.json { render json: @quote_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quote_requests/1
  # DELETE /quote_requests/1.json
  def destroy
    @quote_request.destroy
    respond_to do |format|
      format.html { redirect_to quote_requests_url, notice: 'Quote request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quote_request
      @quote_request = QuoteRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quote_request_params
      params.require(:quote_request).permit(:name, :email, :mobile_number, :category, :upload_file)
    end
end

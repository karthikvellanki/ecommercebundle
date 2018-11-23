class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address_and_authorize, only: [:show, :edit, :update, :destroy]

  # GET /addresses
  # GET /addresses.json
  def index
    @addresses = current_user.addresses
  end

  # GET /addresses/1
  # GET /addresses/1.json
  def show
  end

  # GET /addresses/new
  def new
    @address = Address.new
  end

  # GET /addresses/1/edit
  def edit
  end
  def newaddress
    @user = User.find(params[:id])
    address_type = params[:address_type].nil? ? "user" : params[:address_type]
    @address = @user.addresses.create!(line_1: params[:line_1], line_2: params[:line_2], line_3: params[:line_3], city: params[:city], state: params[:state], pincode: params[:pincode].to_i, name: "shipping")
  end
  # POST /addresses
  # POST /addresses.json
  def create
    @address = Address.new(address_params)

    respond_to do |format|
      if @address.save
        format.html { redirect_to @address, notice: 'Address was successfully created.' }
        format.json { render :show, status: :created, location: @address }
      else
        format.html { render :new }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /addresses/1
  # PATCH/PUT /addresses/1.json
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to @address, notice: 'Address was successfully updated.' }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /addresses/1
  # DELETE /addresses/1.json
  def destroy
    @address.destroy
    respond_to do |format|
      format.html { redirect_to addresses_url, notice: 'Address was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address_and_authorize
      @address = Address.find(params[:id])
      if !current_user.addresses.exists?(@address.id)
        render json: {"error":"You are not authorized for this action"}, :status => 401 and return 
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def address_params
        params.require(:address).permit(:first_name,:last_name,:mobile,:polymorphic, :references, :city, :state, :line_1, :line_2, :line_3, :address_type, :pincode, :name, :default)
    end
end

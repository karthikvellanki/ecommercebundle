class Users::AddressesController < AddressesController
    before_action :set_user
    before_action :set_address, only: [:update]
    before_action :update_session_tab, only: [:create, :update, :destroy]

    def index
        @addresses = current_user.addresses
        respond_to do |format|
          format.html {}
          format.json { render json: @addresses}
        end
    end

    def create
      @address = current_user.addresses.create(address_params)
      respond_to do |format|
          format.html { redirect_to :back, notice: "Address was created successfully"}
          format.json { render json: @address }
      end
    end

    def edit

    end

    def update
      respond_to do |format|
        if @address.update(address_params)
          format.html { redirect_to :back, notice: "Address was updated successfully"}
          format.json { render :show, status: :ok, location: @area }
        else
          format.html { render :edit }
          format.json { render json: @address.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @address.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Address was successfully destroyed.' }
        format.json { head :no_content }
      end
    end


    private

    def set_user
        @user = User.find(current_user.id)
    end

    def set_address
        @address = Address.find(params[:id])
    end

    def update_session_tab
      session[:tab] = nil
      session[:tab] = "address"
    end

    def address_params
        params.require(:address).permit(:first_name,:last_name,:mobile,:line_1, :line_2, :line_3, :state, :pincode, :city)
    end

end

class Admin::AddressesController < AddressesController
  before_action :set_addressable
	def create
    @address = @addressable.addresses.new(address_params)
    respond_to do |format|
      if @address.save
        format.html { redirect_to [:edit,:admin, @address.addressable], notice: 'Address was successfully created.' }
        format.json { render :show, status: :created, location: @addressable }
      else
        format.html { render [:edit,:admin, @address.addressable] }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to [:edit,:admin, @address.addressable], notice: 'Address updated'}
        format.json { render :show, status: :ok, location: user_path(current_user.id) }
      else
        format.html { redirect_to [:edit,:admin, @address.addressable] }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end
	private
	def set_addressable
		resource, id = request.path.split('/')[2,3]
		@addressable = resource.singularize.classify.constantize.find(id)
	end
end

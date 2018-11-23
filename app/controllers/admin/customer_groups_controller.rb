class Admin::CustomerGroupsController < ApplicationController
	before_action :set_customer_group, only: [:search_group]
  before_action :authenticate_user!
  before_action :require_admin_or_provider
  layout 'sidenav'
  
  def create
    @customer_group = CustomerGroup.new(customer_group_params)

    respond_to do |format|
      if @customer_group.save
        format.html { redirect_to admin_group_path(@customer_group.group), notice: 'group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy_multiple
  	customer_group = CustomerGroup.where(id: params[:customer_ids].split(","))
    customer_group.destroy_all

    respond_to do |format|
      format.html { redirect_to admin_group_path(params[:group_id]), notice: 'customer group Deleted' }
      format.json { head :no_content}
    end
  end

  private

  	def set_customer_group
      @customer_group = CustomerGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_group_params
      params.require(:customer_group).permit(:user_id, :group_id)
    end
end

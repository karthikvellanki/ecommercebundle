class Admin::GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :require_admin_or_provider
  layout 'sidenav'

  def index
    @groups = Group.where(provider_id: current_user.provider.id)
  end


  def show
  end

  def new
    @group = Group.new
  end


  def edit
  end


  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to admin_group_path(@group), notice: 'group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to admin_group_path(@group), notice: 'group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy_multiple
  	group = Group.where(id: params[:group_ids].split(","))
    group.destroy_all

    respond_to do |format|
      format.html { redirect_to admin_groups_path, notice: 'customer group Deleted' }
      format.json { head :no_content}
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = current_user.provider.supplier_groups.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :description, :provider_id)
    end
end

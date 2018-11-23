class Admin::GroupProductsController < ApplicationController
	before_action :set_group_product, only: [:edit, :update]
  before_action :authenticate_user!
  before_action :require_admin_or_provider
  layout 'sidenav'
  require 'csv'

  def new
    @group_product = GroupProduct.new
  end


  def create
  	product = Product.where(sku: params[:group_product][:sku]).last
		group = Group.find(params[:group_product][:group_id])
		if product
			@group_product = GroupProduct.new(product_id: product.id, sku: params[:group_product][:sku], group_id: params[:group_product][:group_id], price: params[:group_product][:price])
			respond_to do |format|
				if @group_product.save
					format.html { redirect_to admin_group_path(group), :notice => "Successfully created."}
				else
					format.html { redirect_to admin_group_path(group), :notice => "Error creating group product."}
				end
			end
		else
			respond_to do |format|
				format.html { redirect_to admin_group_path(group), :notice => "Error creating group product."}
			end
		end

  end

  def edit

  end

	def update
		respond_to do |format|
			if @group_product.update_attributes group_product_params
				format.html { redirect_to admin_group_path(@group_product.group)}
				format.json { render :show, status: :ok, location: @group_product }
			else
				format.html { render :edit }
				format.json { render json: @group_product.errors, status: :unprocessable_entity }
			end
		end
	end

  def csv_import
		group_id = params[:group_id]
		if params[:file].present?
			file_data = params[:file].read
			csv_rows  = CSV.parse(file_data)
			csv_rows.each do |row|
				product = Product.where(sku: row[0].gsub("+AC0","")).first
				if product.present?
					group_product = GroupProduct.new(product_id: product.id, sku: row[0].gsub("+AC0",""), price_cents: row[1], group_id: group_id)
					group_product.save
				end
			end
		end
		respond_to do |format|
			format.html { redirect_to admin_group_path(group_id), :notice => "Successfully imported the CSV file." }
		end
	end

  def set_group_product
      @group_product = GroupProduct.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def group_product_params
      params.require(:group_product).permit(:product_id, :group_id, :provider_id, :sku, :price)
    end

end

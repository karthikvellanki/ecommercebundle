class StoresController < ApplicationController
  before_action :set_store, only: [:show, :categories]
  layout "visitor", only: [:index]


  # GET /stores
  # GET /stores.json
  def index
    @stores = Provider.all
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
  end

  def categories
  	@categories = SupplierCategory.where(parent: nil, provider_id: @store.present? ? @store.id : nil)
  end

  def parent_category
  	session[:parent_id] = request.url.split('/').last
  	# @category_list = SupplierCategory.where(provider_id: current_user.provider.id, parent: nil)
  	@categories = SupplierCategory.where(parent_id: session[:parent_id])
    @breadcrumb_array = []
    category = @categories.present? ? @categories.first : SupplierCategory.find(session[:parent_id])
    while category.present? do
      @breadcrumb_array << [category.id, category.name]
      category = category.parent.present? ? category.parent : nil
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_store
    if @current_supplier.present?
      @store = @current_supplier
    elsif params[:provider_id].present?
      @store = @current_supplier
    else
      @store = nil
    end
  end

end

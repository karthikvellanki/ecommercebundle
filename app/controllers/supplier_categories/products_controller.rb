class SupplierCategories::ProductsController < ProductsController
 before_action :set_supplier_category
 layout "stores"
 
 def index
	 	@products = @supplier_category.products
	 	@products = @products.paginate(:page => params[:page], :per_page => 24)
	 	@breadcrumb_array = []
	 	@categories = SupplierCategory.where(parent_id: session[:parent_id])
	  category = @categories.present? ? @categories.first : SupplierCategory.find(session[:parent_id])
	  while category.present? do
	    @breadcrumb_array << [category.id, category.name]
	    category = category.parent.present? ? category.parent : nil
	  end
 end

 private

 def set_supplier_category
 		@supplier_category = SupplierCategory.find(params[:supplier_category_id])
 end

end

class Api::V1::ProductsController < Api::V1::ApiController

	def index
		@products = current_supplier.products
		if @products
			render json: @products
		end
	end

	def barcode
		if current_supplier.products.where("meta#>>'{barcode_value1}' = '#{params[:product][:barcode_value]}'").present?
			@product = current_supplier.products.where("meta#>>'{barcode_value1}' = '#{params[:product][:barcode_value]}'")
		elsif current_supplier.products.where("meta#>>'{barcode_value2}' = '#{params[:product][:barcode]}'").present?
			@product = current_supplier.products.where("meta#>>'{barcode_value2}' = '#{params[:product][:barcode_value]}'")
		else
			@product = current_supplier.products.where(barcode_value: params[:product][:barcode_value])
		end
		if @product.present?
			render json: { product: @product}, status: "201"
		else
			render json: { message: "No product found for this barcode" }, status: "404"
		end
	end

	private

	def product_params
    params.require(:product).permit(:name, :description, :barcode_value)
  end
end
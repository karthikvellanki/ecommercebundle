class Api::V1::CartItemsController < Api::V1::ApiController
	
	before_action :set_cart_item, only: [:update, :destroy]

	def index
		@cart = Cart.find_or_create_by(user_id: current_user.id, provider: current_supplier)
		if @cart
			render json: @cart, status: "201"
		end
	end

	def create
		product = Product.find(cart_item_params[:product_id])
		provider = product.provider
		@cart = Cart.find_by(user_id: current_user.id, provider: current_supplier)
		unless @cart
			@cart = Cart.create(user_id: current_user.id, provider_id: provider)
		end
		@product = @cart.cart_items.find_by(product_id: cart_item_params[:product_id])
		if @product.present?
			@cart.cart_items.where(product_id: cart_item_params[:product_id]).update(quantity: (@product.quantity + cart_item_params[:quantity].to_i))
		else
			@cart.cart_items.create cart_item_params
		end
		render json: @cart, status: "201"
	end

	def update
		@cart_item.update cart_item_params
		if @cart_item
			@cart_items = Cart.find_by(user_id: current_user.id, provider: current_supplier)
			render json: @cart_items, status: "201"
		else
			render json: { message: "Something went wrong" }, status: "401"
		end
	end

	def destroy
		@cart_item.destroy
		if @cart_item
			@cart_items = Cart.find_by(user_id: current_user.id, provider: current_supplier)
			render json: @cart_items, status: "201"
		else
			render json: { message: "Something went wrong" }, status: "401"
		end
	end


	private

	def set_cart_item
    @cart_item = CartItem.find(params[:id])
  end

	def cart_item_params
    params.require(:cart_item).permit(:id, :cart_id, :product_id, :quantity)
  end
end	
require 'test_helper'

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart_item = cart_items(:one)
  end

  test "should get index" do
    get cart_items_url
    assert_response :success
  end

  test "should get new" do
    get new_cart_item_url
    assert_response :success
  end

  test "should create cart_item" do
    assert_difference('CartItem.count') do
      post cart_items_url, params: { cart_item: { cart_id: @cart_item.cart_id, quantity: @cart_item.quantity } }
    end

    assert_redirected_to cart_item_url(CartItem.last)
  end

  test "should show cart_item" do
    get cart_item_url(@cart_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_cart_item_url(@cart_item)
    assert_response :success
  end

  test "should update cart_item" do
    patch cart_item_url(@cart_item), params: { cart_item: { cart_id: @cart_item.cart_id, quantity: @cart_item.quantity } }
    assert_redirected_to cart_item_url(@cart_item)
  end

  test "should destroy cart_item" do
    assert_difference('CartItem.count', -1) do
      delete cart_item_url(@cart_item)
    end

    assert_redirected_to cart_items_url
  end
end

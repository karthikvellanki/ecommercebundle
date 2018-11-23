require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @address = addresses(:one)
  end

  test "should get index" do
    get addresses_url
    assert_response :success
  end

  test "should get new" do
    get new_address_url
    assert_response :success
  end

  test "should create address" do
    assert_difference('Address.count') do
      post addresses_url, params: { address: { address_type: @address.address_type, city: @address.city, line_1: @address.line_1, line_2: @address.line_2, line_3: @address.line_3, name: @address.name, pincode: @address.pincode, state: @address.state } }
    end

    assert_redirected_to address_url(Address.last)
  end

  test "should show address" do
    get address_url(@address)
    assert_response :success
  end

  test "should get edit" do
    get edit_address_url(@address)
    assert_response :success
  end

  test "should update address" do
    patch address_url(@address), params: { address: { address_type: @address.address_type, city: @address.city, line_1: @address.line_1, line_2: @address.line_2, line_3: @address.line_3, name: @address.name, pincode: @address.pincode, state: @address.state } }
    assert_redirected_to address_url(@address)
  end

  test "should destroy address" do
    assert_difference('Address.count', -1) do
      delete address_url(@address)
    end

    assert_redirected_to addresses_url
  end
end

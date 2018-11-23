require 'test_helper'

class QuoteRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quote_request = quote_requests(:one)
  end

  test "should get index" do
    get quote_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_quote_request_url
    assert_response :success
  end

  test "should create quote_request" do
    assert_difference('QuoteRequest.count') do
      post quote_requests_url, params: { quote_request: { category: @quote_request.category, email: @quote_request.email, mobile_number: @quote_request.mobile_number, name: @quote_request.name } }
    end

    assert_redirected_to quote_request_url(QuoteRequest.last)
  end

  test "should show quote_request" do
    get quote_request_url(@quote_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_quote_request_url(@quote_request)
    assert_response :success
  end

  test "should update quote_request" do
    patch quote_request_url(@quote_request), params: { quote_request: { category: @quote_request.category, email: @quote_request.email, mobile_number: @quote_request.mobile_number, name: @quote_request.name } }
    assert_redirected_to quote_request_url(@quote_request)
  end

  test "should destroy quote_request" do
    assert_difference('QuoteRequest.count', -1) do
      delete quote_request_url(@quote_request)
    end

    assert_redirected_to quote_requests_url
  end
end

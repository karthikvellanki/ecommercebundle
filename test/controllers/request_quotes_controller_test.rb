require 'test_helper'

class RequestQuotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @request_quote = request_quotes(:one)
  end

  test "should get index" do
    get request_quotes_url
    assert_response :success
  end

  test "should get new" do
    get new_request_quote_url
    assert_response :success
  end

  test "should create request_quote" do
    assert_difference('RequestQuote.count') do
      post request_quotes_url, params: { request_quote: { description: @request_quote.description, item_number: @request_quote.item_number, product_name: @request_quote.product_name, quantity: @request_quote.quantity } }
    end

    assert_redirected_to request_quote_url(RequestQuote.last)
  end

  test "should show request_quote" do
    get request_quote_url(@request_quote)
    assert_response :success
  end

  test "should get edit" do
    get edit_request_quote_url(@request_quote)
    assert_response :success
  end

  test "should update request_quote" do
    patch request_quote_url(@request_quote), params: { request_quote: { description: @request_quote.description, item_number: @request_quote.item_number, product_name: @request_quote.product_name, quantity: @request_quote.quantity } }
    assert_redirected_to request_quote_url(@request_quote)
  end

  test "should destroy request_quote" do
    assert_difference('RequestQuote.count', -1) do
      delete request_quote_url(@request_quote)
    end

    assert_redirected_to request_quotes_url
  end
end

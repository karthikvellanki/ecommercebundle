require 'test_helper'

class AggregationRoundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aggregation_round = aggregation_rounds(:one)
  end

  test "should get index" do
    get aggregation_rounds_url
    assert_response :success
  end

  test "should get new" do
    get new_aggregation_round_url
    assert_response :success
  end

  test "should create aggregation_round" do
    assert_difference('AggregationRound.count') do
      post aggregation_rounds_url, params: { aggregation_round: { end_date: @aggregation_round.end_date, product_id: @aggregation_round.product_id, qty_limit: @aggregation_round.qty_limit, start_date: @aggregation_round.start_date } }
    end

    assert_redirected_to aggregation_round_url(AggregationRound.last)
  end

  test "should show aggregation_round" do
    get aggregation_round_url(@aggregation_round)
    assert_response :success
  end

  test "should get edit" do
    get edit_aggregation_round_url(@aggregation_round)
    assert_response :success
  end

  test "should update aggregation_round" do
    patch aggregation_round_url(@aggregation_round), params: { aggregation_round: { end_date: @aggregation_round.end_date, product_id: @aggregation_round.product_id, qty_limit: @aggregation_round.qty_limit, start_date: @aggregation_round.start_date } }
    assert_redirected_to aggregation_round_url(@aggregation_round)
  end

  test "should destroy aggregation_round" do
    assert_difference('AggregationRound.count', -1) do
      delete aggregation_round_url(@aggregation_round)
    end

    assert_redirected_to aggregation_rounds_url
  end
end

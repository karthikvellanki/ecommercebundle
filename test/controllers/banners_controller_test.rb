require 'test_helper'

class BannersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @banner = banners(:one)
  end

  test "should get index" do
    get banners_url
    assert_response :success
  end

  test "should get new" do
    get new_banner_url
    assert_response :success
  end

  test "should create banner" do
    assert_difference('Banner.count') do
      post banners_url, params: { banner: { button_text: @banner.button_text, description: @banner.description, link: @banner.link, title: @banner.title } }
    end

    assert_redirected_to banner_url(Banner.last)
  end

  test "should show banner" do
    get banner_url(@banner)
    assert_response :success
  end

  test "should get edit" do
    get edit_banner_url(@banner)
    assert_response :success
  end

  test "should update banner" do
    patch banner_url(@banner), params: { banner: { button_text: @banner.button_text, description: @banner.description, link: @banner.link, title: @banner.title } }
    assert_redirected_to banner_url(@banner)
  end

  test "should destroy banner" do
    assert_difference('Banner.count', -1) do
      delete banner_url(@banner)
    end

    assert_redirected_to banners_url
  end
end

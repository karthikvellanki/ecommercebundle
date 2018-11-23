require 'test_helper'

class SupplierCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @supplier_category = supplier_categories(:one)
  end

  test "should get index" do
    get supplier_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_supplier_category_url
    assert_response :success
  end

  test "should create supplier_category" do
    assert_difference('SupplierCategory.count') do
      post supplier_categories_url, params: { supplier_category: { description: @supplier_category.description, name: @supplier_category.name } }
    end

    assert_redirected_to supplier_category_url(SupplierCategory.last)
  end

  test "should show supplier_category" do
    get supplier_category_url(@supplier_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_supplier_category_url(@supplier_category)
    assert_response :success
  end

  test "should update supplier_category" do
    patch supplier_category_url(@supplier_category), params: { supplier_category: { description: @supplier_category.description, name: @supplier_category.name } }
    assert_redirected_to supplier_category_url(@supplier_category)
  end

  test "should destroy supplier_category" do
    assert_difference('SupplierCategory.count', -1) do
      delete supplier_category_url(@supplier_category)
    end

    assert_redirected_to supplier_categories_url
  end
end

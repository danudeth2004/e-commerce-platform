# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root renders" do
    get root_path
    assert_response :success
  end

  test "flash_sale renders without layout wrapper expectation" do
    get home_flash_sale_path
    assert_response :success
  end

  test "product show renders for active store product" do
    _store, product = active_store_and_product
    get product_path(product)
    assert_response :success
  end
end

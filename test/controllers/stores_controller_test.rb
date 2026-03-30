# frozen_string_literal: true

require "test_helper"

class StoresControllerTest < ActionDispatch::IntegrationTest
  test "show renders for active store" do
    store, _product = active_store_and_product
    get store_path(store)
    assert_response :success
  end

  test "show with category filter" do
    store, _product = active_store_and_product
    get store_path(store, category: "serum")
    assert_response :success
  end

  test "show returns not found for inactive store" do
    store = create_store!
    assert store.inactive?

    get store_path(store)
    assert_response :not_found
  end
end

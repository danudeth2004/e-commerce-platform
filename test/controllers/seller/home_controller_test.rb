# frozen_string_literal: true

require "test_helper"

class Seller::HomeControllerTest < ActionDispatch::IntegrationTest
  test "index redirects to new store when seller has no store" do
    sign_in create_seller_user!, scope: :seller_user
    get seller_root_path
    assert_redirected_to new_seller_store_path
  end

  test "index renders when seller has store" do
    seller = create_seller_user!
    create_store!(owner: seller)
    sign_in seller, scope: :seller_user
    get seller_root_path
    assert_response :success
  end

  test "index search applies store query" do
    seller = create_seller_user!
    store = create_store!(owner: seller)
    store.update!(status: :active)
    create_standard_product!(store: store, title: "UniqueSearchSerum", sku: "SKU-SRCH-#{SecureRandom.hex(4)}")
    sign_in seller, scope: :seller_user
    get seller_root_path, params: { q: "UniqueSearch" }
    assert_response :success
  end
end

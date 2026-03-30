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
end

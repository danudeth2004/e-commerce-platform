# frozen_string_literal: true

require "test_helper"

class Seller::StoresControllerTest < ActionDispatch::IntegrationTest
  test "new redirects when not signed in" do
    get new_seller_store_path
    assert_redirected_to new_seller_user_session_path
  end

  test "new renders when seller signed in without store" do
    sign_in create_seller_user!, scope: :seller_user
    get new_seller_store_path
    assert_response :success
  end
end

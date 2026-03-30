# frozen_string_literal: true

require "test_helper"

class DeviseWiringTest < ActionDispatch::IntegrationTest
  test "buyer session new" do
    get new_user_session_path
    assert_response :success
  end

  test "buyer registration new" do
    get new_user_registration_path
    assert_response :success
  end

  test "admin session new" do
    get new_admin_user_session_path
    assert_response :success
  end

  test "admin registration new" do
    get new_admin_user_registration_path
    assert_response :success
  end

  test "seller session new" do
    get new_seller_user_session_path
    assert_response :success
  end

  test "seller registration new" do
    get new_seller_user_registration_path
    assert_response :success
  end

  test "seller session create redirects per after_sign_in" do
    seller = create_seller_user!
    post seller_user_session_path, params: {
      seller_user: { email: seller.email, password: "password123" }
    }
    assert_redirected_to seller_root_path
  end

  test "seller registration create redirects to seller root" do
    email = "new-seller-#{SecureRandom.hex(4)}@example.com"
    assert_difference -> { Seller::User.count }, 1 do
      post seller_user_registration_path, params: {
        seller_user: {
          email: email,
          password: "password123",
          password_confirmation: "password123",
          first_name: "First",
          last_name: "Last",
          phone_number: "0812345678"
        }
      }
    end
    assert_redirected_to seller_root_path
  end

  test "admin sign in redirects to admin root" do
    admin = create_admin_user!
    post admin_user_session_path, params: {
      admin_user: { email: admin.email, password: "password123" }
    }
    assert_redirected_to admin_root_path
  end
end

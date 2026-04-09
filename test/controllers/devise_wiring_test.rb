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

  test "buyer registration create redirects to root" do
    email = "new-buyer-#{SecureRandom.hex(4)}@example.com"
    assert_difference -> { User.count }, 1 do
      post user_registration_path, params: {
        user: {
          email: email,
          password: "password123",
          password_confirmation: "password123",
          first_name: "First",
          last_name: "Last",
          phone_number: "0812345678"
        }
      }
    end
    assert_redirected_to users_profile_path
  end

  test "admin session new" do
    get new_admin_user_session_path
    assert_response :success
  end

  test "admin registration new redirects when not signed in as admin" do
    get new_admin_user_registration_path
    assert_redirected_to new_admin_user_session_path
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

  test "buyer suspended cannot sign in" do
    user = create_user!
    user.suspended!
    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }
    assert_redirected_to new_user_session_path
  end

  test "signed in buyer is signed out when account becomes suspended" do
    user = create_user!
    sign_in user, scope: :user
    user.suspended!
    get root_path
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_response :success
    get cart_path
    assert_redirected_to new_user_session_path
  end
end

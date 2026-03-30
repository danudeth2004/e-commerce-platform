# frozen_string_literal: true

require "test_helper"

class Users::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "index redirects when not signed in" do
    get users_orders_path
    assert_redirected_to new_user_session_path
  end

  test "index renders when signed in" do
    sign_in create_user!
    get users_orders_path
    assert_response :success
  end
end

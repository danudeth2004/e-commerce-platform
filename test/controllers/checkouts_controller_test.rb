# frozen_string_literal: true

require "test_helper"

class CheckoutsControllerTest < ActionDispatch::IntegrationTest
  test "create_order redirects when not signed in" do
    post create_order_checkout_path
    assert_redirected_to new_user_session_path
  end

  test "payment redirects when not signed in" do
    get payment_checkout_path(order_id: 1)
    assert_redirected_to new_user_session_path
  end
end

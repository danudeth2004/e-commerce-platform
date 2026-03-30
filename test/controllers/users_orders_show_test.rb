# frozen_string_literal: true

require "test_helper"

class UsersOrdersShowTest < ActionDispatch::IntegrationTest
  test "show order" do
    user = create_user!
    sign_in user
    order = Order.create!(user: user, status: :pending)

    get users_order_path(order)
    assert_response :success
  end

  test "index with status filter" do
    user = create_user!
    sign_in user
    get users_orders_path(status: "pending")
    assert_response :success
  end
end

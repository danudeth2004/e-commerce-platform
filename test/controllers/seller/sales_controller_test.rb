# frozen_string_literal: true

require "test_helper"

class Seller::SalesControllerTest < ActionDispatch::IntegrationTest
  test "index redirects when seller has no store" do
    sign_in create_seller_user!, scope: :seller_user
    get seller_sales_path
    assert_redirected_to new_seller_store_path
  end

  test "index renders sales summary" do
    seller = create_seller_user!
    store = create_store!(owner: seller)
    buyer = create_user!
    product = create_standard_product!(store: store)
    order = Order.create!(
      user: buyer,
      status: :paid,
      total_amount_cents: 1000,
      paid_at: Time.current
    )
    OrderItem.create!(
      order: order,
      product: product,
      quantity: 1,
      sku: product.sku,
      title: product.title,
      amount_cents: 1000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 900,
      amount_currency: "THB"
    )

    sign_in seller, scope: :seller_user
    get seller_sales_path
    assert_response :success
    assert_match "รายรับและประวัติการขาย", response.body
    assert_match "ยอดรับสะสม", response.body
  end
end

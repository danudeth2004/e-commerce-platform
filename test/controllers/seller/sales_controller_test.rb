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
    assert_match "ยอดรับในช่วงที่เลือก", response.body
    assert_match "จากวันที่", response.body
  end

  test "index accepts from and to date params" do
    seller = create_seller_user!
    create_store!(owner: seller)
    sign_in seller, scope: :seller_user
    d = Date.current
    get seller_sales_path, params: { from: d.to_s, to: d.to_s }
    assert_response :success
    assert_match d.strftime("%d/%m/%Y"), response.body
  end

  test "index ignores invalid date param and falls back to default range" do
    seller = create_seller_user!
    create_store!(owner: seller)
    sign_in seller, scope: :seller_user
    get seller_sales_path, params: { from: "not-a-valid-date", to: Time.zone.today.to_s }
    assert_response :success
    assert_match "รายรับและประวัติการขาย", response.body
  end

  test "parse_date_param returns nil on invalid date string" do
    controller = Seller::SalesController.new
    assert_nil controller.send(:parse_date_param, "not-a-valid-date")
  end

  test "clamp_date_range caps span to MAX_RANGE_DAYS" do
    controller = Seller::SalesController.new
    to = Date.new(2026, 8, 1)
    from = to - 500.days
    start_d, end_d = controller.send(:clamp_date_range, from, to)
    assert_equal to, end_d
    assert_equal 366, (end_d - start_d).to_i
    assert_equal end_d - Seller::SalesController::MAX_RANGE_DAYS.days, start_d
  end
end

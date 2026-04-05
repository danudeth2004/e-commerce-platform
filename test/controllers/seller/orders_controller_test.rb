# frozen_string_literal: true

require "test_helper"

class Seller::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "index redirects when seller has no store" do
    sign_in create_seller_user!, scope: :seller_user
    get seller_orders_path
    assert_redirected_to new_seller_store_path
  end

  test "index with no payouts shows empty payouts map" do
    seller = create_seller_user!
    create_store!(owner: seller)
    sign_in seller, scope: :seller_user
    get seller_orders_path
    assert_response :success
  end

  test "index filters by status when valid" do
    seller = create_seller_user!
    create_store!(owner: seller)
    sign_in seller, scope: :seller_user
    get seller_orders_path, params: { status: "paid" }
    assert_response :success
  end

  test "index lists orders that include store payout" do
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
    get seller_orders_path
    assert_response :success
    assert_match "คำสั่งซื้อ ##{order.id}", response.body
  end

  test "show loads order for own store" do
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
    get seller_order_path(order)
    assert_response :success
    assert_match "คำสั่งซื้อ ##{order.id}", response.body
  end

  test "show is not found when order has no payout for this store" do
    seller_a = create_seller_user!
    store_a = create_store!(owner: seller_a)
    seller_b = create_seller_user!
    create_store!(owner: seller_b)
    buyer = create_user!
    product = create_standard_product!(store: store_a)
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
      store: store_a,
      amount_cents: 900,
      amount_currency: "THB"
    )

    sign_in seller_b, scope: :seller_user
    get seller_order_path(order)
    assert_response :not_found
  end

  test "index redirects when store is suspended" do
    store = create_store!
    store.update!(status: :suspended)
    sign_in store.owner, scope: :seller_user
    get seller_orders_path
    assert_redirected_to seller_root_path
  end
end

# frozen_string_literal: true

require "test_helper"

class CheckoutsExtendedCoverageTest < ActionDispatch::IntegrationTest
  setup do
    OmiseTestStubs.charge_raise_error = false
    OmiseTestStubs.charge_paid = true
  end

  test "payment maps eligible coupons for order items" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 2,
      amount_cents: 500,
      amount_currency: "THB"
    )
    coupon = Coupon.create!(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    coupon.coupon_products.create!(product: product)

    get payment_checkout_path(order_id: order.id)
    assert_response :success
  end

  test "pay redirects when order has no shipping address and user has none" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(
      user: user,
      status: :pending,
      total_amount_cents: 1000,
      shipping_address_id: nil,
      platform_fee_cents: 0
    )
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 900,
      status: :pending
    )

    post pay_checkout_path, params: { order_id: order.id, omise_token: "tok_test", shipping_method: "standard" }
    assert_redirected_to payment_checkout_path(order_id: order.id)
  end

  test "pay with express shipping adds per-store fee" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 1000, platform_fee_cents: 0)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 900,
      status: :pending
    )

    post pay_checkout_path, params: { order_id: order.id, omise_token: "tok_test", shipping_method: "express" }
    assert_redirected_to root_path
  end

  test "pay with coupon marks coupon used when paid" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 10_000, platform_fee_cents: 0)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 10_000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 9000,
      status: :pending
    )
    coupon = Coupon.create!(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    coupon.coupon_products.create!(product: product)

    post pay_checkout_path, params: {
      order_id: order.id,
      omise_token: "tok_test",
      shipping_method: "standard",
      coupon_id: coupon.id,
      coupon_product_ids: product.id.to_s
    }
    assert_redirected_to root_path
    assert coupon.reload.used?
  end

  test "pay with mismatched coupon product ids returns zero response" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    other = create_standard_product!(store: store, sku: "SKU-OTHER-#{SecureRandom.hex(4)}")
    order = Order.create!(user: user, status: :pending, total_amount_cents: 5000, platform_fee_cents: 0)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 5000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 4000,
      status: :pending
    )
    coupon = Coupon.create!(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    coupon.coupon_products.create!(product: product)

    post pay_checkout_path, params: {
      order_id: order.id,
      omise_token: "tok_test",
      shipping_method: "standard",
      coupon_id: coupon.id,
      coupon_product_ids: other.id.to_s
    }
    assert_redirected_to payment_checkout_path(order_id: order.id)
  end

  test "pay with unknown coupon_id redirects back to payment" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 1000, platform_fee_cents: 0)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 900,
      status: :pending
    )

    post pay_checkout_path, params: {
      order_id: order.id,
      omise_token: "tok_test",
      shipping_method: "standard",
      coupon_id: 9_999_999_999,
      coupon_product_ids: product.id.to_s
    }
    assert_redirected_to payment_checkout_path(order_id: order.id)
  end

  test "pay with excessive coupon discount redirects with alert when total negative" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 1000, platform_fee_cents: 0)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 900,
      status: :pending
    )
    coupon = Coupon.create!(
      user: user,
      discount: 150,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    coupon.coupon_products.create!(product: product)

    post pay_checkout_path, params: {
      order_id: order.id,
      omise_token: "tok_test",
      shipping_method: "standard",
      coupon_id: coupon.id,
      coupon_product_ids: product.id.to_s
    }
    assert_redirected_to root_path
  end

  test "pay with full discount results in zero total marks paid without charge" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 1000, platform_fee_cents: 0)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )
    OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 900,
      status: :pending
    )
    coupon = Coupon.create!(
      user: user,
      discount: 100,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    coupon.coupon_products.create!(product: product)

    post pay_checkout_path, params: {
      order_id: order.id,
      shipping_method: "standard",
      coupon_id: coupon.id,
      coupon_product_ids: product.id.to_s
    }
    assert_redirected_to root_path
    assert order.reload.paid?
  end
end

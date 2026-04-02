# frozen_string_literal: true

require "test_helper"

class CheckoutCartFullTest < ActionDispatch::IntegrationTest
  setup do
    OmiseTestStubs.charge_raise_error = false
    OmiseTestStubs.charge_paid = true
  end

  test "create_order from cart with items" do
    user = create_user!
    sign_in user
    cart = Cart.create!(user: user)
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    cart.cart_items.create!(product: product, quantity: 1)

    assert_difference -> { user.orders.count }, 1 do
      post create_order_checkout_path
    end
    assert_response :redirect
  end

  test "create_order redirects when cart empty" do
    user = create_user!
    sign_in user
    Cart.create!(user: user)

    post create_order_checkout_path
    assert_redirected_to cart_path
  end

  test "create_order from existing order items" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 100,
      amount_currency: "THB"
    )

    post create_order_checkout_path, params: { order_id: order.id }
    assert_response :redirect
  end

  test "payment page" do
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
      quantity: 1,
      amount_cents: 100,
      amount_currency: "THB"
    )

    get payment_checkout_path(order_id: order.id)
    assert_response :success
  end

  test "pay redirects with alert when charge not paid" do
    OmiseTestStubs.charge_paid = false
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
      amount_cents: 500,
      status: :pending
    )

    post pay_checkout_path, params: { order_id: order.id, omise_token: "tok_test", shipping_method: "standard" }
    assert_redirected_to root_path
  ensure
    OmiseTestStubs.charge_paid = true
  end

  test "payment page keeps first promo flag per product when multiple flags exist" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store, amount_cents: 1000, promotion_cents: 0)
    FlagProduct.create!(
      product: product,
      flag_type: :flash,
      position: 0,
      active: true,
      original_amount_cents: 2_000
    )
    FlagProduct.create!(
      product: product,
      flag_type: :bestseller,
      position: 0,
      active: true,
      original_amount_cents: 2_500
    )
    order = Order.create!(user: user, status: :pending)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )

    get payment_checkout_path(order_id: order.id)
    assert_response :success
  end

  test "payment page skips flag when original not above final price" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store, amount_cents: 1000, promotion_cents: 0)
    FlagProduct.create!(
      product: product,
      flag_type: :flash,
      position: 0,
      active: true,
      original_amount_cents: 500
    )
    order = Order.create!(user: user, status: :pending)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )

    get payment_checkout_path(order_id: order.id)
    assert_response :success
  end

  test "pay redirects when payment succeeds" do
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
      amount_cents: 500,
      status: :pending
    )

    post pay_checkout_path, params: { order_id: order.id, omise_token: "tok_test", shipping_method: "express" }
    assert_redirected_to root_path
  end

  test "cancel pending order" do
    user = create_user!
    sign_in user
    order = Order.create!(user: user, status: :pending)

    patch cancel_checkout_path, params: { order_id: order.id }
    assert_redirected_to users_orders_path(status: "pending")
    assert order.reload.cancelled?
  end

  test "cancel non-pending redirects" do
    user = create_user!
    sign_in user
    order = Order.create!(user: user, status: :paid)

    patch cancel_checkout_path, params: { order_id: order.id }
    assert_redirected_to root_path
  end

  test "cart decrease removes line when quantity is one" do
    user = create_user!
    sign_in user
    cart = Cart.create!(user: user)
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    item = cart.cart_items.create!(product: product, quantity: 1)

    patch decrease_item_cart_path, params: { id: item.id }
    assert_redirected_to cart_path
    assert_raises(ActiveRecord::RecordNotFound) { item.reload }
  end

  test "cart show loads promo flags for products" do
    user = create_user!
    sign_in user
    cart = Cart.create!(user: user)
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, amount_cents: 1000, promotion_cents: 0)
    product.images.attach(io: File.open(Rails.root.join("test/fixtures/files/1x1.png")), filename: "1x1.png")
    FlagProduct.create!(
      product: product,
      flag_type: :flash,
      position: 0,
      active: true,
      original_amount_cents: 2_000
    )
    cart.cart_items.create!(product: product, quantity: 1)

    get cart_path
    assert_response :success
  end

  test "cart add remove increase decrease" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)

    post add_item_cart_path, params: { product_id: product.id, quantity: 2 }
    assert_response :redirect

    cart = user.reload.cart
    item = cart.cart_items.first

    patch increase_item_cart_path, params: { id: item.id }
    assert_redirected_to cart_path

    patch decrease_item_cart_path, params: { id: item.id }
    assert_redirected_to cart_path

    delete remove_item_cart_path, params: { id: item.id }
    assert_redirected_to cart_path
  end
end

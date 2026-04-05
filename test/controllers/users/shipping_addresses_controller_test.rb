# frozen_string_literal: true

require "test_helper"

class Users::ShippingAddressesControllerTest < ActionDispatch::IntegrationTest
  def valid_attrs
    {
      label: "บ้าน",
      recipient_name: "ทดสอบ รับ",
      phone_number: "0812345678",
      address_detail: "99 ถนนทดสอบ",
      province_id: 1,
      district_id: 1001,
      sub_district_id: 100_101,
      postal_code: "10200",
      is_default: true
    }
  end

  test "index lists addresses and supports order_id and return_to" do
    user = create_user!
    create_shipping_address!(user)
    sign_in user

    get users_shipping_addresses_path
    assert_response :success

    order = Order.create!(user: user)
    get users_shipping_addresses_path(order_id: order.id, return_to: "/products")
    assert_response :success

    get users_shipping_addresses_path(return_to: "//evil.com")
    assert_response :success
  end

  test "create redirects to cart when return_to is cart and order_id present" do
    user = create_user!
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 1000)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )

    post users_shipping_addresses_path,
      params: {
        order_id: order.id,
        return_to: "/cart",
        shipping_address: valid_attrs
      }
    assert_redirected_to cart_path
  end

  test "select_for_checkout updates order and redirects" do
    user = create_user!
    addr = create_shipping_address!(user)
    sign_in user
    store = create_store!
    store.update!(status: :active, omise_recipient_id: "recp_x")
    product = create_standard_product!(store: store)
    order = Order.create!(user: user, status: :pending, total_amount_cents: 1000)
    order.order_items.create!(
      product: product,
      title: product.title,
      sku: product.sku,
      quantity: 1,
      amount_cents: 1000,
      amount_currency: "THB"
    )

    patch select_for_checkout_users_shipping_address_path(addr),
      params: { order_id: order.id, return_to: "/users/profile" }
    assert_redirected_to users_profile_path
    assert_equal addr.id, order.reload.shipping_address_id
  end

  test "update and destroy" do
    user = create_user!
    sign_in user
    addr = create_shipping_address!(user)

    patch users_shipping_address_path(addr),
      params: { shipping_address: valid_attrs.merge(address_detail: "แก้ไขที่อยู่") }
    assert_response :redirect

    delete users_shipping_address_path(addr)
    assert_response :redirect
    assert_raises(ActiveRecord::RecordNotFound) { addr.reload }
  end

  test "create and update validation failure renders form" do
    user = create_user!
    sign_in user

    post users_shipping_addresses_path, params: { shipping_address: valid_attrs.merge(address_detail: "") }
    assert_response :unprocessable_entity

    addr = create_shipping_address!(user)
    patch users_shipping_address_path(addr),
      params: { shipping_address: valid_attrs.merge(address_detail: "") }
    assert_response :unprocessable_entity
  end

  test "new with checkout context" do
    user = create_user!
    sign_in user
    get new_users_shipping_address_path(order_id: 1, return_to: "/checkout")
    assert_response :success
  end

  test "edit loads form with checkout context" do
    user = create_user!
    addr = create_shipping_address!(user)
    sign_in user
    get edit_users_shipping_address_path(addr, order_id: 1, return_to: "/checkout")
    assert_response :success
  end

  test "update redirects to return_to when no order_id" do
    user = create_user!
    addr = create_shipping_address!(user)
    sign_in user
    patch users_shipping_address_path(addr),
      params: {
        return_to: "/products",
        shipping_address: valid_attrs.merge(address_detail: "แก้ไขแล้ว")
      }
    assert_redirected_to "/products"
  end

  test "destroy promotes another address when deleting default" do
    user = create_user!
    first = create_shipping_address!(user, label: "บ้าน", is_default: true)
    second = create_shipping_address!(user, label: "ออฟฟิศ", is_default: false)
    sign_in user

    delete users_shipping_address_path(first)
    assert_response :redirect
    assert second.reload.is_default?
  end
end

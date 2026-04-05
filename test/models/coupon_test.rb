# frozen_string_literal: true

require "test_helper"

class CouponTest < ActiveSupport::TestCase
  test "active? when valid and not used" do
    user = create_user!
    c = Coupon.create!(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    assert c.active?
  end

  test "valid_for_order? when product matches" do
    user = create_user!
    store = create_store!
    store.update!(status: :active)
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
    c = Coupon.create!(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    c.coupon_products.create!(product: product)
    assert c.valid_for_order?(order)
  end

  test "product_title_for_display from linked products" do
    user = create_user!
    store = create_store!
    store.update!(status: :active)
    p1 = create_standard_product!(store: store, sku: "SKU-PT1-#{SecureRandom.hex(3)}", title: "Alpha")
    p2 = create_standard_product!(store: store, sku: "SKU-PT2-#{SecureRandom.hex(3)}", title: "Beta")
    c = Coupon.create!(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    assert_equal "—", c.product_title_for_display

    c.coupon_products.create!(product: p1)
    c.reload
    assert_equal "Alpha", c.product_title_for_display

    c.coupon_products.create!(product: p2)
    c.reload
    assert_equal "Alpha และอีก 1 รายการ", c.product_title_for_display
  end

  test "expires_after_started validation" do
    user = create_user!
    c = Coupon.new(
      user: user,
      discount: 10,
      min_order: 0,
      started_at: 2.days.from_now,
      expires_at: 1.day.from_now,
      used: false
    )
    assert_not c.valid?
    assert c.errors[:expires_at].any?
  end
end

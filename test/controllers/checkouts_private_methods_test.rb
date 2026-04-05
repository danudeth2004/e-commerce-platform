# frozen_string_literal: true

require "test_helper"

class CheckoutsPrivateMethodsTest < ActiveSupport::TestCase
  test "promo_flags_for_checkout returns empty hash for empty ids" do
    c = CheckoutsController.new
    assert_equal({}, c.send(:promo_flags_for_checkout, []))
  end

  test "calculate_coupon_discount returns zero when below min order" do
    user = create_user!
    store = create_store!
    store.update!(status: :active)
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
    coupon = Coupon.create!(
      user: user,
      discount: 20,
      min_order: 999,
      started_at: 1.day.ago,
      expires_at: 1.day.from_now,
      used: false
    )
    coupon.coupon_products.create!(product: product)

    ctrl = CheckoutsController.new
    assert_equal 0, ctrl.send(:calculate_coupon_discount, order, coupon, [ product.id ])
  end

  test "promo_flags_for_checkout keeps first flag per product" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, amount_cents: 1000, promotion_cents: 0)
    FlagProduct.create!(
      product: product,
      flag_type: :flash,
      position: 0,
      active: true,
      original_amount_cents: 2_000
    )
    ctrl = CheckoutsController.new
    res = ctrl.send(:promo_flags_for_checkout, [ product.id ])
    assert_equal 1, res.size
  end
end

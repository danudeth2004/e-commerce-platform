# frozen_string_literal: true

require "test_helper"

class OrderStorePayoutTest < ActiveSupport::TestCase
  test "belongs to order and store" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 500,
      amount_currency: "THB"
    )
    assert_equal order, payout.order
    assert_equal store, payout.store
    assert payout.pending?
  end

  test "seller_amounts_by_day_for_store sums paid orders for one store" do
    user = create_user!
    store = create_store!
    product = create_standard_product!(store: store)
    paid_at = Time.zone.parse("2026-04-01 14:00:00")
    order = Order.create!(
      user: user,
      status: :paid,
      paid_at: paid_at,
      total_amount_cents: 1000
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
      amount_cents: 500,
      amount_currency: "THB"
    )

    since = 7.days.ago.beginning_of_day
    by_day = OrderStorePayout.seller_amounts_by_day_for_store(store_id: store.id, since: since)
    assert_equal 500, by_day.values.sum
  end

  test "seller_amounts_by_day_for_paid_orders sums all stores" do
    user = create_user!
    store = create_store!
    product = create_standard_product!(store: store)
    paid_at = Time.zone.parse("2026-04-02 10:00:00")
    order = Order.create!(
      user: user,
      status: :paid,
      paid_at: paid_at,
      total_amount_cents: 1000
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
      amount_cents: 400,
      amount_currency: "THB"
    )

    since = 30.days.ago.beginning_of_day
    by_day = OrderStorePayout.seller_amounts_by_day_for_paid_orders(since: since)
    assert_operator by_day.values.sum, :>=, 400
  end
end

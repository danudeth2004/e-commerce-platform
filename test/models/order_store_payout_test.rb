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
end

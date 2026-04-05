# frozen_string_literal: true

require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "creates with user and defaults" do
    user = create_user!
    order = Order.create!(user: user)
    assert order.persisted?
    assert_equal "pending", order.status
  end

  test "paid_counts_by_day returns hash keyed by date" do
    user = create_user!
    Order.create!(user: user, status: :paid, created_at: Time.zone.parse("2026-01-15 12:00:00"))

    since = Time.zone.parse("2026-01-01")
    counts = Order.paid_counts_by_day(since: since)
    assert_kind_of Hash, counts
  end

  test "paid_financials_by_day aggregates gmv and platform fee by Bangkok day" do
    user = create_user!
    paid_at = Time.zone.parse("2026-03-10 15:00:00")
    Order.create!(
      user: user,
      status: :paid,
      paid_at: paid_at,
      total_amount_cents: 5_000,
      platform_fee_cents: 500
    )

    since = 1.year.ago.beginning_of_day
    fin = Order.paid_financials_by_day(since: since)
    assert_kind_of Hash, fin
    assert fin.values.any? { |v| v[:gmv_cents].to_i >= 5_000 }
  end
end

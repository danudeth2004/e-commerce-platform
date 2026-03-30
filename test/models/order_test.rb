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
end

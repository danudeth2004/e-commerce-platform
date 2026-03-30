# frozen_string_literal: true

require "test_helper"

class AppVisitEventTest < ActiveSupport::TestCase
  test "creates with path" do
    e = AppVisitEvent.create!(path: "/products")
    assert e.persisted?
  end

  test "counts_by_day returns hash" do
    AppVisitEvent.create!(path: "/", session_key: "abc")
    since = 1.week.ago
    counts = AppVisitEvent.counts_by_day(since: since)
    assert_kind_of Hash, counts
  end

  test "distinct_sessions_by_day" do
    AppVisitEvent.create!(path: "/", session_key: "sess1")
    since = 1.week.ago
    counts = AppVisitEvent.distinct_sessions_by_day(since: since)
    assert_kind_of Hash, counts
  end
end

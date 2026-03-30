# frozen_string_literal: true

require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  test "valid campaign" do
    c = Campaign.new(
      name: "Summer #{SecureRandom.hex(2)}",
      slug: "summer-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 15
    )
    assert c.valid?
  end

  test "slug generated from name when blank" do
    c = Campaign.create!(
      name: "Winter Sale",
      slug: "",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 5
    )
    assert_equal "winter-sale", c.slug
  end

  test "ends_at must be after starts_at" do
    c = Campaign.new(
      name: "X",
      slug: "x-#{SecureRandom.hex(4)}",
      starts_at: 2.days.from_now,
      ends_at: 1.day.from_now,
      discount_percent: 10
    )
    assert_not c.valid?
    assert c.errors[:ends_at].any?
  end

  test "cannot attach bundle products" do
    store = create_store!
    bundle = create_bundle_product!(store: store)
    c = Campaign.new(
      name: "Y",
      slug: "y-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 10,
      product_ids: [ bundle.id ]
    )
    assert_not c.valid?
  end

  test "apply_discount_to_cents" do
    c = Campaign.new(discount_percent: 20)
    assert_equal 800, c.apply_discount_to_cents(1000)

    c.discount_percent = 0
    assert_equal 1000, c.apply_discount_to_cents(1000)
  end

  test "active_at scope" do
    Campaign.create!(
      name: "A",
      slug: "a-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 5
    )
    assert Campaign.active_at.exists?
  end
end

# frozen_string_literal: true

require "test_helper"

class CampaignProductTest < ActiveSupport::TestCase
  test "allows standard product" do
    store = create_store!
    product = create_standard_product!(store: store)
    campaign = Campaign.create!(
      name: "C",
      slug: "c-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 5
    )
    cp = CampaignProduct.new(campaign: campaign, product: product)
    assert cp.valid?
  end

  test "rejects bundle product" do
    store = create_store!
    bundle = create_bundle_product!(store: store)
    campaign = Campaign.create!(
      name: "C2",
      slug: "c2-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 5
    )
    cp = CampaignProduct.new(campaign: campaign, product: bundle)
    assert_not cp.valid?
  end
end

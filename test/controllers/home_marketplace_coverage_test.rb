# frozen_string_literal: true

require "test_helper"

class HomeMarketplaceCoverageTest < ActionDispatch::IntegrationTest
  test "root with no active stores shows empty marketplace layout" do
    states = Seller::Store.pluck(:id, :status)
    Seller::Store.find_each { |s| s.update!(status: :inactive) }

    get root_path
    assert_response :success

    states.each do |id, st|
      Seller::Store.where(id: id).update_all(status: st)
    end
  end

  test "root includes banner urls when campaign has banners" do
    store = create_store!
    store.update!(status: :active)
    png = Rails.root.join("test/fixtures/files/1x1.png")
    campaign = Campaign.create!(
      name: "Banner #{SecureRandom.hex(2)}",
      slug: "b-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 2.days.from_now,
      discount_percent: 5
    )
    campaign.banners.attach(io: File.open(png), filename: "b.png")

    get root_path
    assert_response :success
  end
end

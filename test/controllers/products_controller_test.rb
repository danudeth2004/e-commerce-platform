# frozen_string_literal: true

require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup_active_campaign_with_product(unique_title: "CampaignProduct#{SecureRandom.hex(4)}")
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, title: unique_title)
    campaign = Campaign.create!(
      name: "Camp #{SecureRandom.hex(2)}",
      slug: "c-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 2.days.from_now,
      discount_percent: 5,
      product_ids: [ product.id ]
    )
    [ campaign, product ]
  end

  test "index renders" do
    get products_path
    assert_response :success
  end

  test "index accepts skin_concern and category params" do
    get products_path(skin_concern: "acne_skin", category: "serum")
    assert_response :success
  end

  test "index accepts search query" do
    get products_path(q: "serum")
    assert_response :success
  end

  test "campaign renders without search" do
    campaign, product = setup_active_campaign_with_product
    get products_campaign_path(id: campaign.id)
    assert_response :success
    assert_includes response.body, product.title
  end

  test "campaign applies ILIKE filter when q is present" do
    unique = "SearchMatch#{SecureRandom.hex(4)}"
    campaign, product = setup_active_campaign_with_product(unique_title: unique)
    get products_campaign_path(id: campaign.id, q: unique[0..6])
    assert_response :success
    assert_includes response.body, product.title
  end

  test "campaign blank q does not apply filter" do
    unique = "NoFilter#{SecureRandom.hex(4)}"
    campaign, product = setup_active_campaign_with_product(unique_title: unique)
    get products_campaign_path(id: campaign.id, q: "   ")
    assert_response :success
    assert_includes response.body, product.title
  end

  test "campaign search with no matches omits product titles" do
    unique = "OnlyThis#{SecureRandom.hex(4)}"
    campaign, product = setup_active_campaign_with_product(unique_title: unique)
    get products_campaign_path(id: campaign.id, q: "zzzznomatch")
    assert_response :success
    assert_not_includes response.body, product.title
  end
end

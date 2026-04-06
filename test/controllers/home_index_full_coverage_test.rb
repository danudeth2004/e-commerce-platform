# frozen_string_literal: true

require "test_helper"

# Exercises HomeController private helpers via GET / (flash sale pipeline, bestsellers, payloads).
class HomeIndexFullCoverageTest < ActionDispatch::IntegrationTest
  test "root loads with flash sale sources and bestsellers" do
    store = create_store!
    store.update!(status: :active)
    png_path = Rails.root.join("test/fixtures/files/1x1.png")

    p_flag = create_standard_product!(
      store: store,
      sku: "SKU-FL-#{SecureRandom.hex(4)}",
      amount_cents: 1_000,
      promotion_cents: 800,
      promotion_starts_at: 1.day.ago,
      promotion_ends_at: 2.days.from_now
    )
    p_flag.images.attach(io: File.open(png_path), filename: "1x1.png")
    FlagProduct.create!(
      product: p_flag,
      flag_type: :flash,
      position: 0,
      active: true,
      original_amount_cents: 1_500
    )

    comp_a = create_standard_product!(store: store, sku: "SKU-CA-#{SecureRandom.hex(4)}", amount_cents: 400)
    comp_b = create_standard_product!(store: store, sku: "SKU-CB-#{SecureRandom.hex(4)}", amount_cents: 400)
    [ comp_a, comp_b ].each do |p|
      p.images.attach(io: File.open(png_path), filename: "1x1.png")
    end

    bundle = create_bundle_product!(
      store: store,
      sku: "SKU-BDL-#{SecureRandom.hex(4)}",
      amount_cents: 500,
      skin_concern_keys: "acne_skin,oily_skin",
      skin_concern_key: "acne_skin"
    )
    bundle.images.attach(io: File.open(png_path), filename: "1x1.png")
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: comp_a,
      position: 0,
      usage_instructions: "a"
    )
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: comp_b,
      position: 1,
      usage_instructions: "b"
    )

    p_sale = create_standard_product!(
      store: store,
      sku: "SKU-SALE-#{SecureRandom.hex(4)}",
      amount_cents: 2_000,
      promotion_cents: 1_000,
      promotion_starts_at: 1.day.ago,
      promotion_ends_at: 1.day.from_now
    )
    p_sale.images.attach(io: File.open(png_path), filename: "1x1.png")

    camp = Campaign.create!(
      name: "Camp #{SecureRandom.hex(2)}",
      slug: "camp-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 2.days.from_now,
      discount_percent: 15,
      product_ids: [ p_sale.id ]
    )

    user = create_user!
    order = Order.create!(user: user, status: :paid)
    order.order_items.create!(
      product: p_flag,
      title: p_flag.title,
      sku: p_flag.sku,
      quantity: 3,
      amount_cents: 300,
      amount_currency: "THB"
    )

    get root_path
    assert_response :success
  end
end

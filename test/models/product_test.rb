# frozen_string_literal: true

require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "standard product is valid" do
    store = create_store!
    p = create_standard_product!(store: store)
    assert p.persisted?
    assert p.standard?
  end

  test "bundle product requires bundle_set_type_key and skin concerns" do
    store = create_store!
    p = create_bundle_product!(store: store)
    assert p.valid?
    assert p.bundle?
  end

  test "bundle invalid without skin_concern_keys" do
    store = create_store!
    p = Product.new(
      store: store,
      title: "B",
      sku: "SKU-#{SecureRandom.alphanumeric(8).upcase}",
      category_key: "bundle",
      kind: :bundle,
      bundle_set_type_key: "facial_routine",
      skin_concern_keys: "",
      amount_cents: 1000,
      promotion_cents: 0
    )
    assert_not p.valid?
  end

  test "promotion_ends_at must be after starts_at" do
    store = create_store!
    p = Product.new(
      store: store,
      title: "T",
      sku: "SKU-#{SecureRandom.alphanumeric(8).upcase}",
      category_key: "serum",
      volume: 30,
      volume_unit: "ml",
      amount_cents: 1000,
      promotion_cents: 0,
      promotion_starts_at: 2.days.from_now,
      promotion_ends_at: 1.day.from_now
    )
    assert_not p.valid?
    assert p.errors[:promotion_ends_at].any?
  end

  test "final_price_cents for standard uses campaigns" do
    store = create_store!
    product = create_standard_product!(store: store, amount_cents: 1000, promotion_cents: 0)
    campaign = Campaign.create!(
      name: "Sale #{SecureRandom.hex(2)}",
      slug: "sale-#{SecureRandom.hex(4)}",
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now,
      discount_percent: 10
    )
    campaign.products << product

    price = product.final_price_cents
    assert_equal 900, price
  end

  test "bundle final_price_cents ignores platform campaigns" do
    store = create_store!
    bundle = create_bundle_product!(store: store, amount_cents: 5000, promotion_cents: 0)
    assert_equal 5000, bundle.final_price_cents
  end

  test "title_with_store includes store name" do
    store = create_store!
    product = create_standard_product!(store: store, title: "T")
    assert_includes product.title_with_store, store.name
    assert_includes product.title_with_store, "T"
  end

  test "skin_concern_labels resolves keys" do
    store = create_store!
    product = create_standard_product!(store: store, skin_concern_key: "acne_skin")
    labels = product.skin_concern_labels
    assert_includes labels.join, "ผิว"
  end
end

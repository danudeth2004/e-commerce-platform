# frozen_string_literal: true

require "test_helper"

class ProductCoverageExtraTest < ActiveSupport::TestCase
  test "price_after_product_promotion_cents respects window" do
    store = create_store!
    p = create_standard_product!(
      store: store,
      amount_cents: 1000,
      promotion_cents: 500,
      promotion_starts_at: 1.day.ago,
      promotion_ends_at: 1.day.from_now
    )
    assert_equal 500, p.price_after_product_promotion_cents
  end

  test "bundle_discount_active compares components" do
    store = create_store!
    a = create_standard_product!(store: store, title: "A", sku: "SKU-A-#{SecureRandom.hex(4)}", amount_cents: 500)
    b = create_standard_product!(store: store, title: "B", sku: "SKU-B-#{SecureRandom.hex(4)}", amount_cents: 500)
    bundle = create_bundle_product!(store: store, amount_cents: 400, sku: "SKU-BUN-#{SecureRandom.hex(4)}")
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: a,
      position: 0,
      usage_instructions: "x"
    )
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: b,
      position: 1,
      usage_instructions: "y"
    )

    assert bundle.bundle_discount_active?
  end

  test "skin_concern_labels uses bundle keys when present" do
    store = create_store!
    b = create_bundle_product!(
      store: store,
      sku: "SKU-LAB-#{SecureRandom.hex(4)}",
      skin_concern_keys: "acne_skin,oily_skin",
      skin_concern_key: "acne_skin"
    )
    labels = b.skin_concern_labels
    assert_includes labels, "ผิวเป็นสิว"
    assert_includes labels, "ผิวมัน"
  end

  test "skin_concern_labels falls back to single key" do
    store = create_store!
    p = create_standard_product!(store: store, skin_concern_key: "dry_skin", skin_concern_keys: nil)
    assert_equal [ "ผิวแห้ง" ], p.skin_concern_labels
  end

  test "bundle_skin_concerns_presence rejects invalid key" do
    store = create_store!
    b = Product.new(
      store: store,
      title: "Bad keys",
      sku: "SKU-BAD-#{SecureRandom.hex(4)}",
      category_key: "bundle",
      kind: :bundle,
      bundle_set_type_key: "facial_routine",
      skin_concern_keys: "not_a_real_key",
      skin_concern_key: "not_a_real_key",
      amount_cents: 2_000,
      promotion_cents: 0,
      volume: 1,
      volume_unit: "ชุด"
    )
    assert_not b.valid?
    assert_includes b.errors[:skin_concern_keys].join, "ไม่ถูกต้อง"
  end

  test "skin_concern_labels empty when no keys" do
    store = create_store!
    p = create_standard_product!(store: store)
    p.update_columns(skin_concern_key: nil, skin_concern_keys: nil)
    assert_empty p.reload.skin_concern_labels
  end

  test "promotion_price_applicable when no schedule" do
    store = create_store!
    p = create_standard_product!(
      store: store,
      amount_cents: 1_000,
      promotion_cents: 500,
      promotion_starts_at: nil,
      promotion_ends_at: nil
    )
    assert p.send(:promotion_price_applicable?, Time.current)
  end
end

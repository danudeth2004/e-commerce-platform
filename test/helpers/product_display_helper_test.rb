# frozen_string_literal: true

require "test_helper"

class ProductDisplayHelperTest < ActionView::TestCase
  include ProductDisplayHelper
  include ActionView::Helpers::AssetUrlHelper
  include Rails.application.routes.url_helpers

  def setup
    super
    ActiveStorage::Current.url_options = { host: "test.example.com" }
  end

  test "product_to_card_hash for standard product" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    h = product_to_card_hash(product)
    assert_equal product.id, h[:id]
    assert h[:price].is_a?(Integer)
  end

  test "bundle_product_to_card_hash" do
    store = create_store!
    store.update!(status: :active)
    bundle = create_bundle_product!(store: store)
    h = bundle_product_to_card_hash(bundle)
    assert h[:bundle]
    assert h[:bundle_thumb_urls].is_a?(Array)
  end

  test "product_detail_price_parts" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    parts = product_detail_price_parts(product)
    assert parts[:price].present?
  end

  test "component_product_first_image_url without images" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    assert_nil component_product_first_image_url(product)
  end

  test "product_detail_gallery_image_urls placeholder when empty" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store)
    urls = product_detail_gallery_image_urls(product)
    assert_equal 1, urls.size
    assert_includes urls.first, "placeholder"
  end

  test "product_to_card_hash strike from flag original" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, amount_cents: 1_000, promotion_cents: 0)
    fp = FlagProduct.new(original_amount_cents: 2_000)
    h = product_to_card_hash(product, flag_product: fp)
    assert_equal 20, h[:original_price]
    assert h[:discount_percent].present?
  end

  test "bundle_product_to_card_hash uses list strike when final equals sum but below list price" do
    store = create_store!
    store.update!(status: :active)
    png_path = Rails.root.join("test/fixtures/files/1x1.png")
    comp_a = create_standard_product!(store: store, sku: "SKU-SUM-A-#{SecureRandom.hex(4)}", amount_cents: 500)
    comp_b = create_standard_product!(store: store, sku: "SKU-SUM-B-#{SecureRandom.hex(4)}", amount_cents: 500)
    [ comp_a, comp_b ].each { |p| p.images.attach(io: File.open(png_path), filename: "1x1.png") }
    bundle = create_bundle_product!(
      store: store,
      sku: "SKU-SUM-BUN-#{SecureRandom.hex(4)}",
      amount_cents: 2_000,
      promotion_cents: 1_000,
      promotion_starts_at: 1.day.ago,
      promotion_ends_at: 1.day.from_now
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

    h = bundle_product_to_card_hash(bundle)
    assert_equal 10, h[:price]
    assert_equal 20, h[:original_price]
  end

  test "bundle_product_to_card_hash strike branches" do
    store = create_store!
    store.update!(status: :active)
    png_path = Rails.root.join("test/fixtures/files/1x1.png")
    comp = create_standard_product!(store: store, sku: "SKU-C-#{SecureRandom.hex(4)}", amount_cents: 500)
    comp.images.attach(io: File.open(png_path), filename: "1x1.png")
    bundle = create_bundle_product!(store: store, sku: "SKU-B-#{SecureRandom.hex(4)}", amount_cents: 400)
    bundle.images.attach(io: File.open(png_path), filename: "1x1.png")
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: comp,
      position: 0,
      usage_instructions: "u"
    )

    h = bundle_product_to_card_hash(bundle)
    assert h[:bundle]
    assert h[:original_price].present?

    fp = FlagProduct.new(original_amount_cents: 5_000)
    h2 = bundle_product_to_card_hash(bundle, flag_product: fp)
    assert h2[:original_price].present?
  end

  test "bundle_product_to_card_hash strike from flag when sum and list match final" do
    store = create_store!
    store.update!(status: :active)
    png_path = Rails.root.join("test/fixtures/files/1x1.png")
    comp = create_standard_product!(store: store, sku: "SKU-FG-#{SecureRandom.hex(4)}", amount_cents: 500)
    comp.images.attach(io: File.open(png_path), filename: "1x1.png")
    bundle = create_bundle_product!(
      store: store,
      sku: "SKU-FGB-#{SecureRandom.hex(4)}",
      amount_cents: 500,
      promotion_cents: 0
    )
    bundle.images.attach(io: File.open(png_path), filename: "1x1.png")
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: comp,
      position: 0,
      usage_instructions: "u"
    )

    fp = FlagProduct.new(original_amount_cents: 2_000)
    h = bundle_product_to_card_hash(bundle, flag_product: fp)
    assert_equal 20, h[:original_price]
  end

  test "product_detail_price_parts strike from list when store promo only" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(
      store: store,
      amount_cents: 1_000,
      promotion_cents: 500,
      promotion_starts_at: 1.day.ago,
      promotion_ends_at: 1.day.from_now
    )
    parts = product_detail_price_parts(product)
    assert_equal 5, parts[:price]
    assert_equal 10, parts[:original]
  end

  test "product_detail_price_parts with flash flag" do
    store = create_store!
    store.update!(status: :active)
    product = create_standard_product!(store: store, amount_cents: 1_000, promotion_cents: 0)
    FlagProduct.create!(
      product: product,
      flag_type: :flash,
      position: 0,
      active: true,
      original_amount_cents: 1_500
    )
    parts = product_detail_price_parts(product)
    assert parts[:original].present?
  end

  test "component_product_first_image_url with attachment" do
    store = create_store!
    store.update!(status: :active)
    png_path = Rails.root.join("test/fixtures/files/1x1.png")
    product = create_standard_product!(store: store)
    product.images.attach(io: File.open(png_path), filename: "1x1.png")
    url = component_product_first_image_url(product)
    assert url.present?
  end

  test "product_detail_gallery_image_urls dedupes bundle attachments" do
    store = create_store!
    store.update!(status: :active)
    png_path = Rails.root.join("test/fixtures/files/1x1.png")
    comp = create_standard_product!(store: store, sku: "SKU-GC-#{SecureRandom.hex(4)}")
    comp.images.attach(io: File.open(png_path), filename: "1x1.png")
    bundle = create_bundle_product!(store: store, sku: "SKU-GB-#{SecureRandom.hex(4)}")
    bundle.images.attach(io: File.open(png_path), filename: "1x1.png")
    ProductBundleItem.create!(
      bundle_product: bundle,
      component_product: comp,
      position: 0,
      usage_instructions: "u"
    )
    urls = product_detail_gallery_image_urls(bundle)
    assert urls.size >= 1
  end
end

# frozen_string_literal: true

require "test_helper"

class ProductBundleItemTest < ActiveSupport::TestCase
  test "valid when component is standard and same store" do
    store = create_store!
    bundle = create_bundle_product!(store: store)
    component = create_standard_product!(store: store)
    item = ProductBundleItem.new(
      bundle_product: bundle,
      component_product: component,
      position: 0,
      usage_instructions: "ทาตามลำดับ"
    )
    assert item.valid?
  end

  test "invalid when component is bundle" do
    store = create_store!
    bundle = create_bundle_product!(store: store)
    other_bundle = create_bundle_product!(store: store)
    item = ProductBundleItem.new(
      bundle_product: bundle,
      component_product: other_bundle,
      position: 0,
      usage_instructions: "x"
    )
    assert_not item.valid?
  end

  test "invalid when different stores" do
    store_a = create_store!
    store_b = create_store!
    bundle = create_bundle_product!(store: store_a)
    component = create_standard_product!(store: store_b)
    item = ProductBundleItem.new(
      bundle_product: bundle,
      component_product: component,
      position: 0,
      usage_instructions: "x"
    )
    assert_not item.valid?
  end
end

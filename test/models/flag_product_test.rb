# frozen_string_literal: true

require "test_helper"

class FlagProductTest < ActiveSupport::TestCase
  test "valid flag" do
    store = create_store!
    product = create_standard_product!(store: store)
    fp = FlagProduct.create!(
      product: product,
      flag_type: :flash,
      position: 0
    )
    assert fp.persisted?
  end

  test "unique product per flag_type" do
    store = create_store!
    product = create_standard_product!(store: store)
    FlagProduct.create!(product: product, flag_type: :bestseller, position: 0)
    dup = FlagProduct.new(product: product, flag_type: :bestseller, position: 1)
    assert_not dup.valid?
  end

  test "active scope" do
    store = create_store!
    product = create_standard_product!(store: store)
    FlagProduct.create!(product: product, flag_type: :essential, position: 0, active: true)
    assert FlagProduct.active.exists?
  end
end

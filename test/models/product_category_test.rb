# frozen_string_literal: true

require "test_helper"

class ProductCategoryTest < ActiveSupport::TestCase
  test "keys lists category keys" do
    assert_includes ProductCategory.keys, "serum"
    assert_includes ProductCategory.keys, "bundle"
  end

  test "label_for returns Thai label" do
    assert_equal "เซรั่ม", ProductCategory.label_for("serum")
    assert_nil ProductCategory.label_for(nil)
  end

  test "all returns data rows" do
    assert ProductCategory.all.any?
  end
end

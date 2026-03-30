# frozen_string_literal: true

require "test_helper"

class SellerModuleTest < ActiveSupport::TestCase
  test "table_name_prefix for seller namespace" do
    assert_equal "seller_", Seller.table_name_prefix
  end
end

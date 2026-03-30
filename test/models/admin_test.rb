# frozen_string_literal: true

require "test_helper"

class AdminModuleTest < ActiveSupport::TestCase
  test "table_name_prefix for admin namespace" do
    assert_equal "admin_", Admin.table_name_prefix
  end
end

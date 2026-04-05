# frozen_string_literal: true

require "test_helper"

class AdminHelperTest < ActionView::TestCase
  include AdminHelper
  include ActionView::Helpers::NumberHelper

  test "admin_format_thb zero" do
    assert_equal "฿0.00", admin_format_thb(0)
  end

  test "admin_format_thb non-zero uses number_to_currency" do
    assert_equal "฿123.45", admin_format_thb(12_345)
  end

  test "admin_store_status_label covers variants" do
    s = Seller::Store.new(status: :active)
    assert_equal "ใช้งาน", admin_store_status_label(s)

    s.status = :inactive
    assert_equal "ไม่แสดงหน้าลูกค้า", admin_store_status_label(s)

    s.status = :suspended
    assert_equal "ระงับ", admin_store_status_label(s)

    unknown = Struct.new(:status).new("unknown")
    assert_equal "unknown", admin_store_status_label(unknown)
  end

  test "admin_nav_item_classes" do
    assert_includes admin_nav_item_classes(true), "bg-blue-600"
    assert_includes admin_nav_item_classes(false), "text-slate-300"
  end
end

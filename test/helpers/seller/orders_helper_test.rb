# frozen_string_literal: true

require "test_helper"

class Seller::OrdersHelperTest < ActionView::TestCase
  include Seller::OrdersHelper

  test "seller_order_status_label" do
    o = Struct.new(:status)
    assert_equal "รอชำระเงิน", seller_order_status_label(o.new("pending"))
    assert_equal "ชำระแล้ว", seller_order_status_label(o.new("paid"))
    assert_equal "ยกเลิก", seller_order_status_label(o.new("cancelled"))
    assert_equal "ชำระไม่สำเร็จ", seller_order_status_label(o.new("failed"))
    assert_equal "Other", seller_order_status_label(o.new("other"))
  end

  test "seller_payout_status_label" do
    p = Struct.new(:status)
    assert_equal "รอโอน", seller_payout_status_label(p.new("pending"))
    assert_equal "กำลังโอน", seller_payout_status_label(p.new("processing"))
    assert_equal "โอนแล้ว", seller_payout_status_label(p.new("transferred"))
    assert_equal "โอนล้มเหลว", seller_payout_status_label(p.new("failed"))
    assert_equal "Other", seller_payout_status_label(p.new("other"))
  end
end

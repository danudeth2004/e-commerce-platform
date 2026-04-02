# frozen_string_literal: true

module Seller::OrdersHelper
  def seller_order_status_label(order)
    case order.status
    when "pending" then "รอชำระเงิน"
    when "paid" then "ชำระแล้ว"
    when "cancelled" then "ยกเลิก"
    when "failed" then "ชำระไม่สำเร็จ"
    else order.status.humanize
    end
  end

  def seller_payout_status_label(payout)
    case payout.status
    when "pending" then "รอโอน"
    when "processing" then "กำลังโอน"
    when "transferred" then "โอนแล้ว"
    when "failed" then "โอนล้มเหลว"
    else payout.status.humanize
    end
  end
end

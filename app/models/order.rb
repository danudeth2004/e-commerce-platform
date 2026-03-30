class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :order_store_payouts, dependent: :destroy

  monetize :total_amount_cents
  monetize :shipping_cents
  monetize :platform_fee_cents

  enum :status, {
    cancelled: "cancelled",
    pending: "pending",
    paid: "paid",
    failed: "failed"
  }

  # สำหรับกราฟแดชบอร์ด admin — ออเดอร์ที่ชำระแล้ว รายวัน (โซน Bangkok)
  def self.paid_counts_by_day(since:)
    rows = connection.select_all(
      sanitize_sql_array([
        <<-SQL.squish,
          SELECT (date_trunc('day', timezone('Asia/Bangkok', created_at)))::date AS day,
                 COUNT(*)::bigint AS cnt
          FROM orders
          WHERE created_at >= ?
            AND status = ?
          GROUP BY 1
          ORDER BY 1
        SQL
        since,
        statuses[:paid]
      ])
    )
    rows.each_with_object({}) do |row, h|
      h[Date.parse(row["day"].to_s)] = row["cnt"].to_i
    end
  end
end

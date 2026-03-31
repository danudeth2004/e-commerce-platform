class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :order_store_payouts, dependent: :destroy

  monetize :total_amount_cents
  monetize :shipping_cents
  monetize :discount_cents
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

  # ยอดขายรวม + ค่าธรรมเนียมแพลตฟอร์ม รายวัน (อิง paid_at, โซน Asia/Bangkok)
  def self.paid_financials_by_day(since:)
    rows = connection.select_all(
      sanitize_sql_array([
        <<-SQL.squish,
          SELECT (date_trunc('day', timezone('Asia/Bangkok', paid_at)))::date AS day,
                 COALESCE(SUM(total_amount_cents), 0)::bigint AS gmv_cents,
                 COALESCE(SUM(platform_fee_cents), 0)::bigint AS platform_fee_cents
          FROM orders
          WHERE paid_at IS NOT NULL
            AND paid_at >= ?
            AND status = ?
          GROUP BY 1
          ORDER BY 1
        SQL
        since,
        statuses[:paid]
      ])
    )
    rows.each_with_object({}) do |row, h|
      d = Date.parse(row["day"].to_s)
      h[d] = {
        gmv_cents: row["gmv_cents"].to_i,
        platform_fee_cents: row["platform_fee_cents"].to_i
      }
    end
  end
end

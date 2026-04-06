class OrderStorePayout < ApplicationRecord
  belongs_to :order
  belongs_to :store, class_name: "Seller::Store", foreign_key: :seller_store_id

  monetize :amount_cents

  enum :status, {
    pending: "pending",
    processing: "processing",
    transferred: "transferred",
    failed: "failed"
  }

  default_scope { order(updated_at: :desc) }

  # ยอดที่ต้องโอนร้านรวมต่อวัน (อิงวันที่ชำระเงินของออเดอร์)
  def self.seller_amounts_by_day_for_paid_orders(since:)
    rows = connection.select_all(
      sanitize_sql_array([
        <<-SQL.squish,
          SELECT (date_trunc('day', timezone('Asia/Bangkok', o.paid_at)))::date AS day,
                 COALESCE(SUM(order_store_payouts.amount_cents), 0)::bigint AS seller_cents
          FROM order_store_payouts
          INNER JOIN orders o ON o.id = order_store_payouts.order_id
          WHERE o.paid_at IS NOT NULL
            AND o.paid_at >= ?
            AND o.status = ?
          GROUP BY 1
          ORDER BY 1
        SQL
        since,
        Order.statuses[:paid]
      ])
    )
    rows.each_with_object({}) do |row, h|
      h[Date.parse(row["day"].to_s)] = row["seller_cents"].to_i
    end
  end

  # ยอดรับของร้านหนึ่งต่อวัน (อิง paid_at, โซน Asia/Bangkok)
  # end_at — ถ้ามี จำกัดออเดอร์ที่ paid_at <= end_at (เช่น end_of_day ของวันสิ้นสุดช่วง)
  def self.seller_amounts_by_day_for_store(store_id:, since:, end_at: nil)
    upper = end_at.present? ? "AND o.paid_at <= ?" : ""
    sql = <<-SQL.squish
      SELECT (date_trunc('day', timezone('Asia/Bangkok', o.paid_at)))::date AS day,
             COALESCE(SUM(order_store_payouts.amount_cents), 0)::bigint AS seller_cents
      FROM order_store_payouts
      INNER JOIN orders o ON o.id = order_store_payouts.order_id
      WHERE order_store_payouts.seller_store_id = ?
        AND o.paid_at IS NOT NULL
        AND o.paid_at >= ?
        #{upper}
        AND o.status = ?
      GROUP BY 1
      ORDER BY 1
    SQL
    args = [ sql, store_id, since ]
    args << end_at if end_at.present?
    args << Order.statuses[:paid]
    rows = connection.select_all(sanitize_sql_array(args))
    rows.each_with_object({}) do |row, h|
      h[Date.parse(row["day"].to_s)] = row["seller_cents"].to_i
    end
  end
end

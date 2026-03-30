# frozen_string_literal: true

class AppVisitEvent < ApplicationRecord
  # นับจำนวนครั้งที่โหลดหน้า (รายวัน ตามโซน Asia/Bangkok)
  def self.counts_by_day(since:)
    rows = connection.select_all(
      sanitize_sql_array([
        <<-SQL.squish,
          SELECT (date_trunc('day', timezone('Asia/Bangkok', created_at)))::date AS day,
                 COUNT(*)::bigint AS cnt
          FROM app_visit_events
          WHERE created_at >= ?
          GROUP BY 1
          ORDER BY 1
        SQL
        since
      ])
    )
    rows.each_with_object({}) do |row, h|
      h[Date.parse(row["day"].to_s)] = row["cnt"].to_i
    end
  end

  # นับ session ที่ไม่ซ้ำต่อวัน (โดยประมาณจาก session ของเบราว์เซอร์)
  def self.distinct_sessions_by_day(since:)
    rows = connection.select_all(
      sanitize_sql_array([
        <<-SQL.squish,
          SELECT (date_trunc('day', timezone('Asia/Bangkok', created_at)))::date AS day,
                 COUNT(DISTINCT session_key)::bigint AS cnt
          FROM app_visit_events
          WHERE created_at >= ?
            AND session_key IS NOT NULL
            AND session_key != ''
          GROUP BY 1
          ORDER BY 1
        SQL
        since
      ])
    )
    rows.each_with_object({}) do |row, h|
      h[Date.parse(row["day"].to_s)] = row["cnt"].to_i
    end
  end
end

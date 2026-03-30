# frozen_string_literal: true

# บันทึกการเข้าชมฝั่งลูกค้า (ไม่รวม admin / seller / rails internal) สำหรับแดชบอร์ด
module TracksAppVisit
  extend ActiveSupport::Concern

  included do
    after_action :track_app_visit, if: :should_track_app_visit?
  end

  private

  def should_track_app_visit?
    return false unless request.get? || request.head?
    return false if request.head?
    return false unless request.format&.html?
    return false if request.get_header("HTTP_SEC_PURPOSE") == "prefetch"

    path = request.path
    return false if path.start_with?("/admin", "/seller", "/rails", "/up", "/cable")
    return false if path.start_with?("/assets", "/packs")

    true
  end

  def track_app_visit
    AppVisitEvent.create!(
      path: request.path.truncate(500),
      session_key: session.id.to_s
    )
  rescue StandardError => e
    Rails.logger.warn("[TracksAppVisit] #{e.class}: #{e.message}")
  end
end

# frozen_string_literal: true

# ใช้เฉพาะใน test (มี route เมื่อ Rails.env.test?) — ทดสอบ ApplicationController#enforce_buyer_not_suspended
class ApplicationSuspendEnforcementController < ApplicationController
  def index
    render plain: "ok"
  end

  private

  def current_user
    @__test_user
  end

  def user_signed_in?
    @__test_user.present?
  end
end

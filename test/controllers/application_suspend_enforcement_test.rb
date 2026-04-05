# frozen_string_literal: true

require "test_helper"

# Isolated controller to exercise ApplicationController#enforce_buyer_not_suspended (suspended? path).
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

class ApplicationSuspendEnforcementTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  tests ApplicationSuspendEnforcementController

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "signs out and redirects suspended buyer" do
    u = create_user!
    u.suspended!
    @controller.instance_variable_set(:@__test_user, u)
    get :index
    assert_redirected_to root_path
    assert_equal I18n.t("devise.failure.suspended"), flash[:alert].to_s
  end
end

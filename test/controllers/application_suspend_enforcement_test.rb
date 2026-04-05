# frozen_string_literal: true

require "test_helper"

# ใช้ ApplicationSuspendEnforcementController ใน app/controllers + route (เฉพาะ test)
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

  test "renders ok when buyer is not suspended" do
    u = create_user!
    u.active!
    @controller.instance_variable_set(:@__test_user, u)
    get :index
    assert_response :success
    assert_equal "ok", @response.body
  end
end

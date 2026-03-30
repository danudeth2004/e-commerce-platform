# frozen_string_literal: true

require "test_helper"

class Admin::HomeControllerTest < ActionDispatch::IntegrationTest
  test "index redirects when not signed in" do
    get admin_root_path
    assert_redirected_to new_admin_user_session_path
  end

  test "index renders when admin signed in" do
    sign_in create_admin_user!, scope: :admin_user
    get admin_root_path
    assert_response :success
  end
end

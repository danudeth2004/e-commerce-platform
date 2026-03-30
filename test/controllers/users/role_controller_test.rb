# frozen_string_literal: true

require "test_helper"

class Users::RoleControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    get users_role_path
    assert_response :success
  end
end

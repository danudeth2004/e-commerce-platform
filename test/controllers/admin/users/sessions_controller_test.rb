# frozen_string_literal: true

require "test_helper"

class Admin::Users::SessionsControllerTest < ActionController::TestCase
  tests Admin::Users::SessionsController

  test "after_sign_out_path_for returns admin sign-in" do
    assert_equal new_admin_user_session_path, @controller.send(:after_sign_out_path_for, nil)
  end
end

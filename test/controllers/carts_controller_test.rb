# frozen_string_literal: true

require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  test "show redirects when not signed in" do
    get cart_path
    assert_redirected_to new_user_session_path
  end

  test "show renders when signed in" do
    sign_in create_user!
    get cart_path
    assert_response :success
  end
end

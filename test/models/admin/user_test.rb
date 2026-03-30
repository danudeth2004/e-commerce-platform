# frozen_string_literal: true

require "test_helper"

class Admin::UserTest < ActiveSupport::TestCase
  test "valid with email and password" do
    u = Admin::User.new(default_admin_user_attributes)
    assert u.valid?
  end

  test "persists" do
    u = create_admin_user!
    assert u.persisted?
    assert_equal "admin_users", u.class.table_name
  end
end

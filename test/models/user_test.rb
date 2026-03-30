# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    user = User.new(default_user_attributes)
    assert user.valid?
  end

  test "invalid without first_name" do
    user = User.new(default_user_attributes.merge(first_name: ""))
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "invalid with bad phone format" do
    user = User.new(default_user_attributes.merge(phone_number: "123"))
    assert_not user.valid?
  end

  test "associations" do
    user = create_user!
    assert_respond_to user, :cart
    assert_respond_to user, :orders
  end
end

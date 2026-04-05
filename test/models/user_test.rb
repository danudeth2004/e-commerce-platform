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
    assert_includes user.errors[:first_name], "ต้องไม่เว้นว่าง"
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

  test "rejects nested shipping address when all core fields blank" do
    attrs = {
      email: "nested-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "First",
      last_name: "Last",
      phone_number: "0812345678",
      shipping_addresses_attributes: {
        "0" => {
          address_detail: "",
          province_id: "",
          district_id: "",
          sub_district_id: "",
          postal_code: ""
        }
      }
    }
    user = User.new(attrs)
    assert user.valid?
    assert_equal 0, user.shipping_addresses.size
  end
end

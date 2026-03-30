# frozen_string_literal: true

require "test_helper"

class Seller::UserTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    u = Seller::User.new(default_seller_user_attributes)
    assert u.valid?
  end

  test "has one store association" do
    u = create_seller_user!
    assert_respond_to u, :store
  end
end

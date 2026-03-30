# frozen_string_literal: true

require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "belongs to user" do
    user = create_user!
    cart = Cart.create!(user: user)
    assert_equal user, cart.user
  end

  test "has many cart_items" do
    user = create_user!
    cart = Cart.create!(user: user)
    store = create_store!
    product = create_standard_product!(store: store)
    cart.cart_items.create!(product: product, quantity: 1)
    assert_equal 1, cart.cart_items.count
  end
end

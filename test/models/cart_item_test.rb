# frozen_string_literal: true

require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "valid with positive quantity" do
    user = create_user!
    cart = Cart.create!(user: user)
    product = create_standard_product!(store: create_store!)
    item = CartItem.new(cart: cart, product: product, quantity: 2)
    assert item.valid?
  end

  test "invalid with zero quantity" do
    user = create_user!
    cart = Cart.create!(user: user)
    product = create_standard_product!(store: create_store!)
    item = CartItem.new(cart: cart, product: product, quantity: 0)
    assert_not item.valid?
  end
end

# frozen_string_literal: true

require "test_helper"

module Orders
  class CreateFromCartTest < ActiveSupport::TestCase
    test "creates order from cart and clears cart" do
      user = create_user!
      cart = Cart.create!(user: user)
      store = create_store!
      store.update!(status: :active, omise_recipient_id: "recp_x")
      product = create_standard_product!(store: store)
      cart.cart_items.create!(product: product, quantity: 2)

      order = Orders::CreateFromCart.new(cart, user: user).call

      assert order.persisted?
      assert order.order_items.any?
      assert_equal 0, cart.reload.cart_items.count
    end

    test "creates order from order_items collection" do
      user = create_user!
      store = create_store!
      store.update!(status: :active, omise_recipient_id: "recp_x")
      product = create_standard_product!(store: store)
      order0 = Order.create!(user: user)
      order0.order_items.create!(
        product: product,
        title: product.title,
        sku: product.sku,
        quantity: 1,
        amount_cents: 100,
        amount_currency: "THB"
      )

      order = Orders::CreateFromCart.new(order0.order_items, user: user).call

      assert order.order_items.any?
    end
  end
end

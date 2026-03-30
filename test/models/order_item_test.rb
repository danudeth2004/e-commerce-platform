# frozen_string_literal: true

require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "belongs to order and product" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    product = create_standard_product!(store: store)
    item = OrderItem.create!(
      order: order,
      product: product,
      quantity: 1,
      sku: product.sku,
      title: product.title,
      amount_cents: 100,
      amount_currency: "THB"
    )
    assert_equal order, item.order
    assert_equal product, item.product
  end
end

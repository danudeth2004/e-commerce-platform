# frozen_string_literal: true

class AddShippingAddressToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :shipping_address, foreign_key: true
    add_column :orders, :shipping_address_snapshot, :text
  end
end

class AddShippingToOrders < ActiveRecord::Migration[8.1]
  def change
    add_monetize :orders, :shipping, null: false, default: 0
  end
end

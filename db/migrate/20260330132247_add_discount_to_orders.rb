class AddDiscountToOrders < ActiveRecord::Migration[8.1]
  def change
    add_monetize :orders, :discount, null: false, default: 0
  end
end

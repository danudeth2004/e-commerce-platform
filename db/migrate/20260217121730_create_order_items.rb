class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.string :title, null: false
      t.string :sku, null: false

      t.integer :quantity, null: false, default: 1
      t.monetize :amount, null: false, default: 0

      t.timestamps
    end
  end
end

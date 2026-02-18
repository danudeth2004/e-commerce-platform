class CreateOrderStorePayouts < ActiveRecord::Migration[7.1]
  def change
    create_table :order_store_payouts do |t|
      t.references :order, null: false, foreign_key: true
      t.references :seller_store, null: false, foreign_key: { to_table: :seller_stores }

      t.monetize :amount, null: false, default: 0

      t.string :transfer_id
      t.string :status, null: false, default: "pending"

      t.datetime :transferred_at

      t.timestamps
    end

    add_index :order_store_payouts, :transfer_id
  end
end

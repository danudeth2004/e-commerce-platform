class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true

      t.string :status, null: false, default: "pending"

      t.string :omise_charge_id
      t.string :omise_source_id

      t.monetize :total_amount, null: false, default: 0
      t.monetize :platform_fee, null: false, default: 0

      t.datetime :paid_at

      t.timestamps
    end

    add_index :orders, :omise_charge_id, unique: true
  end
end

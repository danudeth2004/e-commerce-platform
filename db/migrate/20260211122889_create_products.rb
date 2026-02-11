class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.text :description
      t.string :sku, null: false
      t.monetize :amount, null: false, default: 0
      t.references :seller_store, null: false, foreign_key: { to_table: :seller_stores }

      t.timestamps
    end

    add_index :products, [ :seller_store_id, :sku ], unique: true
  end
end

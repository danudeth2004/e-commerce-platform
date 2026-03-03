class CreateFlagProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :flag_products do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :flag_type, null: false
      t.integer :position, null: false, default: 0
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :flag_products, [ :product_id, :flag_type ], unique: true
    add_index :flag_products, [ :flag_type, :position ]
  end
end

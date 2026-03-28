class AddProductBundles < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :kind, :string, null: false, default: "standard"
    add_column :products, :bundle_set_type_key, :string
    add_index :products, :kind

    create_table :product_bundle_items do |t|
      t.references :bundle_product, null: false, foreign_key: { to_table: :products }
      t.references :component_product, null: false, foreign_key: { to_table: :products }
      t.integer :position, null: false, default: 0
      t.text :usage_instructions
      t.timestamps
    end

    add_index :product_bundle_items, [ :bundle_product_id, :position ]
  end
end

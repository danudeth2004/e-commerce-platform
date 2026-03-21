class AddCategoryKeyToProducts < ActiveRecord::Migration[8.1]
  def up
    add_column :products, :category_key, :string
    add_index :products, :category_key
    execute "UPDATE products SET category_key = 'skin_care' WHERE category_key IS NULL"
  end

  def down
    remove_index :products, :category_key
    remove_column :products, :category_key
  end
end

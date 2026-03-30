class FixProductsStoreIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :products, name: "index_products_on_seller_store_id", if_exists: true
    add_index :products, :seller_store_id, if_not_exists: true
  end
end

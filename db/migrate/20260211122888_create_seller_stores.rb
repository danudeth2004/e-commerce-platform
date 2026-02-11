class CreateSellerStores < ActiveRecord::Migration[8.1]
  def change
    create_table :seller_stores do |t|
      t.references :seller_user, null: false, foreign_key: { to_table: :seller_users }
      t.string :name, null: false
      t.text :description
      t.string :location, null: false

      t.timestamps
    end
  end
end

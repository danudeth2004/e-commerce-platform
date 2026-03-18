class AddStatusToSellerStores < ActiveRecord::Migration[8.1]
  def change
    add_column :seller_stores, :status, :string, null: false, default: "inactive"
  end
end

class AddBankInfoToSellerStores < ActiveRecord::Migration[8.1]
  def change
    add_column :seller_stores, :bank_code, :string
    add_column :seller_stores, :bank_number, :string
    add_column :seller_stores, :bank_name, :string
  end
end

class AddOmiseRecipientToSellerStores < ActiveRecord::Migration[8.1]
  def change
    add_column :seller_stores, :omise_recipient_id, :string
    add_index :seller_stores, :omise_recipient_id
  end
end

class RemoveLocationFromSellerUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :seller_users, :location, :text
  end
end

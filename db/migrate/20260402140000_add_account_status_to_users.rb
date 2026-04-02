# frozen_string_literal: true

class AddAccountStatusToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :account_status, :string, null: false, default: "active"
    add_index :users, :account_status
  end
end

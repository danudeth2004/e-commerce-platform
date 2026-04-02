# frozen_string_literal: true

class CreateShippingAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :shipping_addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label
      t.string :recipient_name
      t.string :phone_number
      t.text :address_detail
      t.integer :province_id
      t.integer :district_id
      t.integer :sub_district_id
      t.string :postal_code
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end

    add_index :shipping_addresses, [ :user_id, :is_default ]
  end
end

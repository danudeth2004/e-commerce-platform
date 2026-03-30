class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.integer :discount, null: false
      t.integer :min_order, null: false, default: 0
      t.boolean :used, null: false, default: false
      t.timestamp :started_at, null: false
      t.timestamp :expires_at, null: false

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

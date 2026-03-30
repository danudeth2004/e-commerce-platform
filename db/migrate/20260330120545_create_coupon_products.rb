class CreateCouponProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :coupon_products do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end

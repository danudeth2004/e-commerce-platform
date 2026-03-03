class AddOriginalAmountToFlagProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :flag_products, :original_amount_cents, :integer
    add_column :flag_products, :original_amount_currency, :string, null: false, default: "THB"
  end
end


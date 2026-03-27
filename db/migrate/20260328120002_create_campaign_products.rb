# frozen_string_literal: true

class CreateCampaignProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_products do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :campaign_products, [ :campaign_id, :product_id ], unique: true
  end
end

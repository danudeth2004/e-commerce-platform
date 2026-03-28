# frozen_string_literal: true

class RemoveBundleProductsFromCampaignProducts < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      DELETE FROM campaign_products
      WHERE product_id IN (SELECT id FROM products WHERE kind = 'bundle')
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

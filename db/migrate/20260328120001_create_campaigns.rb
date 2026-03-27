# frozen_string_literal: true

class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :discount_percent, null: false, default: 0

      t.timestamps
    end

    add_index :campaigns, :slug, unique: true
    add_index :campaigns, [ :starts_at, :ends_at ]
  end
end

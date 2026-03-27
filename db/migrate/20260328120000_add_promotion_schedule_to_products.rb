# frozen_string_literal: true

class AddPromotionScheduleToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :promotion_starts_at, :datetime
    add_column :products, :promotion_ends_at, :datetime
  end
end

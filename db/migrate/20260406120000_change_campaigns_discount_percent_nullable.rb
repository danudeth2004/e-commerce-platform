# frozen_string_literal: true

class ChangeCampaignsDiscountPercentNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :campaigns, :discount_percent, true
    change_column_default :campaigns, :discount_percent, from: 0, to: nil
  end
end

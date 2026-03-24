class AddMissingFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :effect, :string
    add_column :products, :volume, :integer
    add_column :products, :volume_unit, :string
    add_monetize :products, :promotion, null: false, default: 0
    add_column :products, :usage, :text
  end
end

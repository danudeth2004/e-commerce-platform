class AddSkinConcernKeysToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :skin_concern_keys, :string
  end
end

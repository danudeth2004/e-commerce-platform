class AddSkinConcernKeyToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :skin_concern_key, :string
    add_index  :products, :skin_concern_key
  end
end

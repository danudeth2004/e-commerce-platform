# frozen_string_literal: true

class CreateAppVisitEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :app_visit_events do |t|
      t.string :path, null: false, limit: 500
      t.string :session_key, limit: 255

      t.timestamps
    end

    add_index :app_visit_events, :created_at
    add_index :app_visit_events, [ :session_key, :created_at ]
  end
end

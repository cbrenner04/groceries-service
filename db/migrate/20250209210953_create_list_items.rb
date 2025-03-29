class CreateListItems < ActiveRecord::Migration[8.0]
  def change
    create_table :list_items, id: :uuid do |t|
      t.datetime :archived_at
      t.boolean :refreshed, default: false, null: false
      t.boolean :completed, default: false, null: false
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :list, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateSimpleListItems < ActiveRecord::Migration[6.0]
  def change
    create_table :simple_list_items do |t|
      t.references :user, foreign_key: true, null: false
      t.references :simple_list, foreign_key: { to_table: :lists }, null: false
      t.string :content, null: false
      t.boolean :completed, null: false, default: false
      t.boolean :refreshed, null: false, default: false
      t.datetime :archived_at
      t.string :category

      t.timestamps
    end
  end
end

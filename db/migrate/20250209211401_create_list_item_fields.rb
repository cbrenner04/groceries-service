class CreateListItemFields < ActiveRecord::Migration[8.0]
  def change
    create_table :list_item_fields, id: :uuid do |t|
      t.references :list_item_field_configuration, type: :uuid, null: false, foreign_key: true
      t.string :data
      t.datetime :archived_at
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :list_item, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end

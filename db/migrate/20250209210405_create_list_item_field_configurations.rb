class CreateListItemFieldConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :list_item_field_configurations, id: :uuid do |t|
      t.string :label
      t.string :data_type
      t.datetime :archived_at
      t.references :list_item_configuration, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateListItemConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :list_item_configurations, id: :uuid do |t|
      t.references :list, type: :uuid, index: {unique: true}, null: false, foreign_key: true

      t.timestamps
    end
  end
end

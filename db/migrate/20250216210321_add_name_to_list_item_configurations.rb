class AddNameToListItemConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_column :list_item_configurations, :name, :string, null: false
    add_index :list_item_configurations, :name, unique: true

    add_column :list_item_configurations, :allow_other_users_to_view, :boolean, null: false, default: false

    add_reference :list_item_configurations, :user, type: :uuid, foreign_key: true, null: false
  end
end

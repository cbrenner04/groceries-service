class UpdateColumnsOnListItemConfigurations < ActiveRecord::Migration[8.0]
  def change
    remove_index :list_item_configurations, [:name], unique: true
    add_index :list_item_configurations, [:user_id, :name], unique: true

    remove_column :list_item_configurations, :allow_other_users_to_view
  end
end

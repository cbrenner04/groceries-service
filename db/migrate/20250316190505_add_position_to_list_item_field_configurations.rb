class AddPositionToListItemFieldConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_column :list_item_field_configurations, :position, :integer, null: false
  end
end

class AddPrimaryToListItemFieldConfigurations < ActiveRecord::Migration[8.1]
  def change
    add_column :list_item_field_configurations, :primary, :boolean, default: false, null: false
  end
end

class AddUniquenessConstraintToListItemFieldConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_index :list_item_field_configurations, [:label, :list_item_configuration_id],
              unique: true
  end
end

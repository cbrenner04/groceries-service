class AddListItemConfigurationIdToLists < ActiveRecord::Migration[8.0]
  def change
    add_column :lists, :list_item_configuration_id, :uuid
  end
end

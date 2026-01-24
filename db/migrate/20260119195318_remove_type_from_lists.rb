class RemoveTypeFromLists < ActiveRecord::Migration[8.1]
  def change
    update_view :active_lists, version: 4, revert_to_version: 3
    remove_column :lists, :type, :string
  end
end
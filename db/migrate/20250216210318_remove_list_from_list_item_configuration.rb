class RemoveListFromListItemConfiguration < ActiveRecord::Migration[8.0]
  def change
    remove_reference :list_item_configurations, :list, foreign_key: true
  end
end

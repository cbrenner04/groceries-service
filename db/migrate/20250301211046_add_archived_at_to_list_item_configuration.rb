class AddArchivedAtToListItemConfiguration < ActiveRecord::Migration[8.0]
  def change
    add_column :list_item_configurations, :archived_at, :datetime
  end
end

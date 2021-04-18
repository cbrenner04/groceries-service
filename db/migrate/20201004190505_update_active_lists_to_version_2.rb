class UpdateActiveListsToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :active_lists, version: 2, revert_to_version: 1
  end
end

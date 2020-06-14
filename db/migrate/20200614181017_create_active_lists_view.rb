class CreateActiveListsView < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE VIEW active_lists AS
        SELECT lists.id, lists.name, lists.created_at, lists.completed,
              lists.type, lists.refreshed, lists.owner_id,
              users_lists.id as users_list_id, users_lists.user_id as user_id,
              users_lists.has_accepted as has_accepted
        FROM lists
        INNER JOIN users_lists
                ON lists.id = users_lists.list_id
        WHERE lists.archived_at IS NULL
        ORDER BY lists.created_at DESC;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW active_lists
    SQL
  end
end

class UpdateIdsToUuids < ActiveRecord::Migration[6.0]
  def up
    # allows us to use gen_random_uuid()
    enable_extension 'pgcrypto'

    # view fucks with these things so just get it out of the way
    execute "DROP VIEW IF EXISTS active_lists"

    # add uuid column to users, this will be used as the ID later
    add_column :users, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }

    # update owner_id on lists to use users uuid
    add_column :lists, :owner_uuid, :uuid
    execute <<-SQL
      UPDATE lists
      SET owner_uuid = users.uuid
      FROM users
      WHERE lists.owner_id = users.id;
    SQL
    change_column_null :lists, :owner_uuid, false
    remove_column :lists, :owner_id
    rename_column :lists, :owner_uuid, :owner_id
    add_index :lists, :owner_id

    # update assignee_id on to_do_list_items to use uuid
    add_column :to_do_list_items, :assignee_uuid, :uuid
    execute <<-SQL
      UPDATE to_do_list_items
      SET assignee_uuid = users.uuid
      FROM users
      WHERE to_do_list_items.assignee_id = users.id;
    SQL
    remove_column :to_do_list_items, :assignee_id
    rename_column :to_do_list_items, :assignee_uuid, :assignee_id
    add_index :to_do_list_items, :assignee_id

    # update all other tables to use uuid for users
    tables = %w[users_lists book_list_items grocery_list_items music_list_items simple_list_items to_do_list_items]
    tables.each do |table|
      add_column table.to_sym, :user_uuid, :uuid
      execute <<-SQL
        UPDATE #{table}
        SET user_uuid = users.uuid
        FROM users
        WHERE #{table}.user_id = users.id;
      SQL

      change_column_null table.to_sym, :user_uuid, false
      remove_column table.to_sym, :user_id
      rename_column table.to_sym, :user_uuid, :user_id
      add_index table.to_sym, :user_id
    end

    # remove old id and update to new uuid for users
    remove_column :users, :id
    rename_column :users, :uuid, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    tables.each { |table| add_foreign_key table.to_sym, :users }

    # update lists to use uuid for id
    add_column :lists, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }

    # update all other tables to use lists uuid
    tables.each do |table|
      add_column table.to_sym, :list_uuid, :uuid
      execute <<-SQL
        UPDATE #{table}
        SET list_uuid = lists.uuid
        FROM lists
        WHERE #{table}.list_id = lists.id;
      SQL

      change_column_null table.to_sym, :list_uuid, false
      remove_column table.to_sym, :list_id
      rename_column table.to_sym, :list_uuid, :list_id
      add_index table.to_sym, :list_id
    end

    # remove old id and update to new uuid for lists
    remove_column :lists, :id
    rename_column :lists, :uuid, :id
    execute "ALTER TABLE lists ADD PRIMARY KEY (id);"
    tables.each { |table| add_foreign_key table.to_sym, :lists }

    # update all other tables to use uuids
    tables.each do |table|
      add_column table.to_sym, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
      remove_column table.to_sym, :id
      rename_column table.to_sym, :uuid, :id
      execute "ALTER TABLE #{table} ADD PRIMARY KEY (id);"
    end

    # add unique index for user_id and list_id on users_lists. not sure how this wasn't neede before
    add_index :users_lists, [:list_id, :user_id], unique: true

    # add index on created_at to allow for implicit sort to be on created_at
    tables = %w[book_list_items grocery_list_items lists music_list_items simple_list_items to_do_list_items users]
    tables.each { |table| add_index table.to_sym, :created_at }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

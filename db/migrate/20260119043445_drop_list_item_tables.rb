class DropListItemTables < ActiveRecord::Migration[8.1]
  def up
    %w[book_list_items grocery_list_items music_list_items simple_list_items to_do_list_items].each do |table|
      remove_foreign_key table, :lists
      remove_foreign_key table, :users
      drop_table table
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

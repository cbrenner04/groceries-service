class UpdateListIdOnListItems < ActiveRecord::Migration[6.0]
  def up
    # books
    remove_index :book_list_items, :book_list_id
    rename_column :book_list_items, :book_list_id, :list_id
    add_index :book_list_items, :list_id
    # groceries
    remove_index :grocery_list_items, :grocery_list_id
    rename_column :grocery_list_items, :grocery_list_id, :list_id
    add_index :grocery_list_items, :list_id
    # music
    remove_index :music_list_items, :music_list_id
    rename_column :music_list_items, :music_list_id, :list_id
    add_index :music_list_items, :list_id
    # simple
    remove_index :simple_list_items, :simple_list_id
    rename_column :simple_list_items, :simple_list_id, :list_id
    add_index :simple_list_items, :list_id
    # to do
    remove_index :to_do_list_items, :to_do_list_id
    rename_column :to_do_list_items, :to_do_list_id, :list_id
    add_index :to_do_list_items, :list_id
  end

  def down
    # books
    remove_index :book_list_items, :list_id
    rename_column :book_list_items, :list_id, :book_list_id
    add_index :book_list_items, :book_list_id
    # groceries
    remove_index :grocery_list_items, :list_id
    rename_column :grocery_list_items, :list_id, :grocery_list_id
    add_index :grocery_list_items, :grocery_list_id
    # music
    remove_index :music_list_items, :list_id
    rename_column :music_list_items, :list_id, :music_list_id
    add_index :music_list_items, :music_list_id
    # simple
    remove_index :simple_list_items, :list_id
    rename_column :simple_list_items, :list_id, :simple_list_id
    add_index :simple_list_items, :simple_list_id
    # to do
    remove_index :to_do_list_items, :list_id
    rename_column :to_do_list_items, :list_id, :to_do_list_id
    add_index :to_do_list_items, :to_do_list_id
  end
end

# TODO: could use `if_not_exists: true`, but the `create_table` method will
#       still try to create the indexes even if the table exist
#       this is supposedly fixed with Rails 6.1
def create_users
  return if table_exists?("users")

  create_table :users do |t|
    t.string :email, default: "", null: false
    t.string :encrypted_password, default: "", null: false
    t.string :reset_password_token
    t.datetime :reset_password_sent_at
    t.datetime :remember_created_at
    t.integer :sign_in_count, default: 0, null: false
    t.datetime :current_sign_in_at
    t.datetime :last_sign_in_at
    t.inet :current_sign_in_ip
    t.inet :last_sign_in_ip
    t.string :invitation_token
    t.datetime :invitation_created_at
    t.datetime :invitation_sent_at
    t.datetime :invitation_accepted_at
    t.integer :invitation_limit
    t.references :invited_by, polymorphic: true
    t.integer :invitations_count, default: 0
    t.boolean :is_test_account, default: false
    t.string :provider, default: "email", null: false
    t.string :uid, default: "", null: false
    t.text :tokens
    t.boolean :allow_password_change, default: false, null: false
    t.index :email, unique: true
    t.index :invitation_token, unique: true
    t.index :invitations_count
    t.index :invited_by_id
    t.index :reset_password_token, unique: true
    t.index [:uid, :provider], unique: true

    t.timestamps
  end
end

def create_lists
  return if table_exists?("lists")

  create_table :lists do |t|
    t.string :name, null: false
    t.datetime :archived_at
    t.boolean :completed, default: false, null: false
    t.boolean :refreshed, default: false, null: false
    t.string :type
    t.bigint :owner_id, null: false
    t.index :owner_id

    t.timestamps
  end
end

def create_book_list_items
  return if table_exists?("book_list_items")

  create_table :book_list_items do |t|
    t.references :user, foreign_key: true, null: false
    t.references :book_list, foreign_key: { to_table: :lists }, null: false
    t.string :author
    t.string :title
    t.boolean :purchased, default: false, null: false
    t.boolean :read, default: false, null: false
    t.datetime :archived_at
    t.integer :number_in_series
    t.string :category

    t.timestamps
  end
end

def create_grocery_list_items
  return if table_exists?("grocery_list_items")

  create_table :grocery_list_items do |t|
    t.references :user, foreign_key: true, null: false
    t.references :grocery_list, foreign_key: { to_table: :lists }, null: false
    t.string :product, null: false
    t.string :quantity, default: "1", null: false
    t.boolean :purchased, default: false, null: false
    t.datetime :archived_at
    t.boolean :refreshed, default: false, null: false
    t.string :category

    t.timestamps
  end
end

def create_music_list_items
  return if table_exists?("music_list_items")

  create_table :music_list_items do |t|
    t.references :user, foreign_key: true, null: false
    t.references :music_list, foreign_key: { to_table: :lists }, null: false
    t.string :title
    t.string :artist
    t.string :album
    t.boolean :purchased, default: false, null: false
    t.datetime :archived_at
    t.string :category

    t.timestamps
  end
end

def create_to_do_list_items
  return if table_exists?("to_do_list_items")

  create_table :to_do_list_items do |t|
    t.references :user, foreign_key: true, null: false
    t.references :to_do_list, foreign_key: { to_table: :lists }, null: false
    t.string :task, null: false
    t.integer :assignee_id
    t.datetime :due_by
    t.boolean :completed, default: false, null: false
    t.boolean :refreshed, default: false, null: false
    t.datetime :archived_at
    t.string :category

    t.timestamps
  end
end

def create_users_lists
  return if table_exists?("users_lists")

  create_table :users_lists do |t|
    t.references :user, foreign_key: true, null: false
    t.references :list, foreign_key: true, null: false
    t.boolean :has_accepted
    t.string :permissions, default: "write", null: false
    t.index [:user_id, :list_id], unique: true
  end
end


class InitializeDatabase < ActiveRecord::Migration[6.0]
  def change
    create_users
    create_lists
    create_book_list_items
    create_grocery_list_items
    create_music_list_items
    create_to_do_list_items
    create_users_lists
  end
end

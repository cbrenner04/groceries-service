class InitializeDatabase < ActiveRecord::Migration[6.0]
  def change
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

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :invitation_token, unique: true
    add_index :users, :invitations_count
    add_index :users, :invited_by_id
    add_index :users, :reset_password_token, unique: true
    add_index :users, [:uid, :provider], unique: true

    create_table :lists do |t|
      t.string :name, null: false
      t.datetime :archived_at
      t.boolean :completed, default: false, null: false
      t.boolean :refreshed, default: false, null: false
      t.string :type
      t.bigint :owner_id, null: false

      t.timestamps
    end

    add_index :lists, :owner_id

    create_table :book_list_items do |t|
      t.references :user, foreign_key: true, null: false
      t.references :list, foreign_key: true, null: false
      t.string :author
      t.string :title
      t.boolean :purchased, default: false, null: false
      t.boolean :read, default: false, null: false
      t.datetime :archived_at
      t.integer :number_in_series
      t.string :category

      t.timestamps
    end

    remove_index :book_list_items, :list_id
    rename_column :book_list_items, :list_id, :book_list_id
    add_index :book_list_items, :book_list_id

    create_table :grocery_list_items do |t|
      t.references :user, foreign_key: true, null: false
      t.references :list, foreign_key: true, null: false
      t.string :product, null: false
      t.string :quantity
      t.boolean :purchased, default: false, null: false
      t.datetime :archived_at
      t.boolean :refreshed, default: false, null: false
      t.string :category

      t.timestamps
    end

    remove_index :grocery_list_items, :list_id
    rename_column :grocery_list_items, :list_id, :grocery_list_id
    add_index :grocery_list_items, :grocery_list_id

    create_table :music_list_items do |t|
      t.references :user, foreign_key: true, null: false
      t.references :list, foreign_key: true, null: false
      t.string :title
      t.string :artist
      t.string :album
      t.boolean :purchased, default: false, null: false
      t.datetime :archived_at
      t.string :category

      t.timestamps
    end

    remove_index :music_list_items, :list_id
    rename_column :music_list_items, :list_id, :music_list_id
    add_index :music_list_items, :music_list_id

    create_table :to_do_list_items do |t|
      t.references :user, foreign_key: true, null: false
      t.references :list, foreign_key: true, null: false
      t.string :task, null: false
      t.integer :assignee_id
      t.datetime :due_by
      t.boolean :completed, default: false, null: false
      t.boolean :refreshed, default: false, null: false
      t.datetime :archived_at
      t.string :category

      t.timestamps
    end

    remove_index :to_do_list_items, :list_id
    rename_column :to_do_list_items, :list_id, :to_do_list_id
    add_index :to_do_list_items, :to_do_list_id

    create_table :users_lists do |t|
      t.references :user, foreign_key: true, null: false
      t.references :list, foreign_key: true, null: false
      t.boolean :has_accepted
      t.string :permissions, default: "write", null: false
    end

    add_index :users_lists, [:user_id, :list_id], unique: true
  end
end

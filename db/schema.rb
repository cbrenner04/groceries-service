# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_16_210322) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "book_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "author"
    t.string "title"
    t.boolean "purchased", default: false, null: false
    t.boolean "read", default: false, null: false
    t.datetime "archived_at", precision: nil
    t.integer "number_in_series"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.index ["created_at"], name: "index_book_list_items_on_created_at"
    t.index ["list_id"], name: "index_book_list_items_on_list_id"
    t.index ["user_id"], name: "index_book_list_items_on_user_id"
  end

  create_table "grocery_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "product", null: false
    t.string "quantity"
    t.boolean "purchased", default: false, null: false
    t.datetime "archived_at", precision: nil
    t.boolean "refreshed", default: false, null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.index ["created_at"], name: "index_grocery_list_items_on_created_at"
    t.index ["list_id"], name: "index_grocery_list_items_on_list_id"
    t.index ["user_id"], name: "index_grocery_list_items_on_user_id"
  end

  create_table "list_item_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.boolean "allow_other_users_to_view", default: false, null: false
    t.uuid "user_id", null: false
    t.index ["name"], name: "index_list_item_configurations_on_name", unique: true
    t.index ["user_id"], name: "index_list_item_configurations_on_user_id"
  end

  create_table "list_item_field_configurations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.string "data_type"
    t.datetime "archived_at"
    t.uuid "list_item_configuration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_item_configuration_id"], name: "idx_on_list_item_configuration_id_0c41bb26c8"
  end

  create_table "list_item_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "list_item_field_configuration_id", null: false
    t.string "data"
    t.datetime "archived_at"
    t.uuid "user_id", null: false
    t.uuid "list_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_item_field_configuration_id"], name: "index_list_item_fields_on_list_item_field_configuration_id"
    t.index ["list_item_id"], name: "index_list_item_fields_on_list_item_id"
    t.index ["user_id"], name: "index_list_item_fields_on_user_id"
  end

  create_table "list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "archived_at"
    t.boolean "refreshed", default: false, null: false
    t.boolean "completed", default: false, null: false
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_items_on_list_id"
    t.index ["user_id"], name: "index_list_items_on_user_id"
  end

  create_table "lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "archived_at", precision: nil
    t.boolean "completed", default: false, null: false
    t.boolean "refreshed", default: false, null: false
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "owner_id", null: false
    t.uuid "list_item_configuration_id"
    t.index ["created_at"], name: "index_lists_on_created_at"
    t.index ["owner_id"], name: "index_lists_on_owner_id"
  end

  create_table "music_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "artist"
    t.string "album"
    t.boolean "purchased", default: false, null: false
    t.datetime "archived_at", precision: nil
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.index ["created_at"], name: "index_music_list_items_on_created_at"
    t.index ["list_id"], name: "index_music_list_items_on_list_id"
    t.index ["user_id"], name: "index_music_list_items_on_user_id"
  end

  create_table "simple_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "content", null: false
    t.boolean "completed", default: false, null: false
    t.boolean "refreshed", default: false, null: false
    t.datetime "archived_at", precision: nil
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.index ["created_at"], name: "index_simple_list_items_on_created_at"
    t.index ["list_id"], name: "index_simple_list_items_on_list_id"
    t.index ["user_id"], name: "index_simple_list_items_on_user_id"
  end

  create_table "to_do_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "task", null: false
    t.datetime "due_by", precision: nil
    t.boolean "completed", default: false, null: false
    t.boolean "refreshed", default: false, null: false
    t.datetime "archived_at", precision: nil
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "assignee_id"
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.index ["assignee_id"], name: "index_to_do_list_items_on_assignee_id"
    t.index ["created_at"], name: "index_to_do_list_items_on_created_at"
    t.index ["list_id"], name: "index_to_do_list_items_on_list_id"
    t.index ["user_id"], name: "index_to_do_list_items_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.boolean "is_test_account", default: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.boolean "allow_password_change", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "users_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "has_accepted"
    t.string "permissions", default: "write", null: false
    t.uuid "user_id", null: false
    t.uuid "list_id", null: false
    t.uuid "prev_id"
    t.uuid "next_id"
    t.index ["list_id", "user_id"], name: "index_users_lists_on_list_id_and_user_id", unique: true
    t.index ["list_id"], name: "index_users_lists_on_list_id"
    t.index ["user_id"], name: "index_users_lists_on_user_id"
  end

  add_foreign_key "book_list_items", "lists"
  add_foreign_key "book_list_items", "users"
  add_foreign_key "grocery_list_items", "lists"
  add_foreign_key "grocery_list_items", "users"
  add_foreign_key "list_item_configurations", "users"
  add_foreign_key "list_item_field_configurations", "list_item_configurations"
  add_foreign_key "list_item_fields", "list_item_field_configurations"
  add_foreign_key "list_item_fields", "list_items"
  add_foreign_key "list_item_fields", "users"
  add_foreign_key "list_items", "lists"
  add_foreign_key "list_items", "users"
  add_foreign_key "music_list_items", "lists"
  add_foreign_key "music_list_items", "users"
  add_foreign_key "simple_list_items", "lists"
  add_foreign_key "simple_list_items", "users"
  add_foreign_key "to_do_list_items", "lists"
  add_foreign_key "to_do_list_items", "users"
  add_foreign_key "users_lists", "lists"
  add_foreign_key "users_lists", "users"

  create_view "active_lists", sql_definition: <<-SQL
      SELECT lists.id,
      lists.name,
      lists.created_at,
      lists.completed,
      lists.type,
      lists.refreshed,
      lists.owner_id,
      users_lists.id AS users_list_id,
      users_lists.user_id,
      users_lists.has_accepted,
      users_lists.prev_id,
      users_lists.next_id,
      lists.list_item_configuration_id
     FROM (lists
       JOIN users_lists ON ((lists.id = users_lists.list_id)))
    WHERE (lists.archived_at IS NULL)
    ORDER BY lists.created_at DESC;
  SQL
end

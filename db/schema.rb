# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_13_172349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_list_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_list_id", null: false
    t.string "author"
    t.string "title"
    t.boolean "purchased", default: false, null: false
    t.boolean "read", default: false, null: false
    t.datetime "archived_at"
    t.integer "number_in_series"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_list_id"], name: "index_book_list_items_on_book_list_id"
    t.index ["user_id"], name: "index_book_list_items_on_user_id"
  end

  create_table "grocery_list_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "grocery_list_id", null: false
    t.string "product", null: false
    t.string "quantity"
    t.boolean "purchased", default: false, null: false
    t.datetime "archived_at"
    t.boolean "refreshed", default: false, null: false
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grocery_list_id"], name: "index_grocery_list_items_on_grocery_list_id"
    t.index ["user_id"], name: "index_grocery_list_items_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "archived_at"
    t.boolean "completed", default: false, null: false
    t.boolean "refreshed", default: false, null: false
    t.string "type"
    t.bigint "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_id"], name: "index_lists_on_owner_id"
  end

  create_table "music_list_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "music_list_id", null: false
    t.string "title"
    t.string "artist"
    t.string "album"
    t.boolean "purchased", default: false, null: false
    t.datetime "archived_at"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["music_list_id"], name: "index_music_list_items_on_music_list_id"
    t.index ["user_id"], name: "index_music_list_items_on_user_id"
  end

  create_table "simple_list_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "simple_list_id", null: false
    t.string "content", null: false
    t.boolean "completed", default: false, null: false
    t.boolean "refreshed", default: false, null: false
    t.datetime "archived_at"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["simple_list_id"], name: "index_simple_list_items_on_simple_list_id"
    t.index ["user_id"], name: "index_simple_list_items_on_user_id"
  end

  create_table "to_do_list_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "to_do_list_id", null: false
    t.string "task", null: false
    t.integer "assignee_id"
    t.datetime "due_by"
    t.boolean "completed", default: false, null: false
    t.boolean "refreshed", default: false, null: false
    t.datetime "archived_at"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["to_do_list_id"], name: "index_to_do_list_items_on_to_do_list_id"
    t.index ["user_id"], name: "index_to_do_list_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.boolean "is_test_account", default: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.boolean "allow_password_change", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "users_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "list_id", null: false
    t.boolean "has_accepted"
    t.string "permissions", default: "write", null: false
    t.index ["list_id"], name: "index_users_lists_on_list_id"
    t.index ["user_id", "list_id"], name: "index_users_lists_on_user_id_and_list_id", unique: true
    t.index ["user_id"], name: "index_users_lists_on_user_id"
  end

  add_foreign_key "book_list_items", "lists", column: "book_list_id"
  add_foreign_key "book_list_items", "users"
  add_foreign_key "grocery_list_items", "lists", column: "grocery_list_id"
  add_foreign_key "grocery_list_items", "users"
  add_foreign_key "music_list_items", "lists", column: "music_list_id"
  add_foreign_key "music_list_items", "users"
  add_foreign_key "simple_list_items", "lists", column: "simple_list_id"
  add_foreign_key "simple_list_items", "users"
  add_foreign_key "to_do_list_items", "lists", column: "to_do_list_id"
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
      users_lists.has_accepted
     FROM (lists
       JOIN users_lists ON ((lists.id = users_lists.list_id)))
    WHERE (lists.archived_at IS NULL)
    ORDER BY lists.created_at DESC;
  SQL
end

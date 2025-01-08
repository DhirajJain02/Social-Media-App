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

ActiveRecord::Schema[8.0].define(version: 2024_12_26_071410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.bigint "post_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.bigint "like_count", default: 0
    t.bigint "user_id"
    t.index ["post_id"], name: "idx_16509_index_comments_on_post_id"
    t.index ["user_id"], name: "idx_16509_index_comments_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "user_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["post_id"], name: "idx_16517_index_likes_on_post_id"
    t.index ["user_id"], name: "idx_16517_index_likes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.bigint "likes_count", default: 0
    t.text "visibility"
    t.bigint "user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.text "name"
    t.text "resource_type"
    t.bigint "resource_id"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "idx_16491_index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "idx_16491_index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "idx_16491_index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.text "email", default: ""
    t.text "encrypted_password", default: ""
    t.text "reset_password_token"
    t.timestamptz "reset_password_sent_at"
    t.timestamptz "remember_created_at"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.text "first_name"
    t.text "last_name"
    t.text "phone_number"
    t.boolean "active", default: true
    t.index ["email"], name: "idx_16522_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "idx_16522_index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "idx_16497_index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "idx_16497_index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "idx_16497_index_users_roles_on_user_id"
  end

  add_foreign_key "comments", "posts", name: "comments_post_id_fkey"
  add_foreign_key "comments", "users", name: "comments_user_id_fkey"
  add_foreign_key "likes", "posts", name: "likes_post_id_fkey"
  add_foreign_key "likes", "users", name: "likes_user_id_fkey"
end

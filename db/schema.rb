# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180106081045) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.text "description"
    t.bigint "lead_id"
    t.string "website"
    t.string "slack_channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_projects_on_lead_id"
  end

  create_table "projects_skills", id: false, force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "skill_id"
    t.index ["project_id"], name: "index_projects_skills_on_project_id"
    t.index ["skill_id"], name: "index_projects_skills_on_skill_id"
  end

  create_table "projects_volunteers", id: false, force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.index ["project_id"], name: "index_projects_volunteers_on_project_id"
    t.index ["user_id"], name: "index_projects_volunteers_on_user_id"
  end

  create_table "skill_categories", force: :cascade do |t|
    t.string "name"
    t.boolean "tech_stack"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "tech", default: true
  end

  create_table "skills_categories_matching", force: :cascade do |t|
    t.bigint "skill_id"
    t.bigint "skill_category_id"
    t.index ["skill_category_id"], name: "index_skills_categories_matching_on_skill_category_id"
    t.index ["skill_id"], name: "index_skills_categories_matching_on_skill_id"
  end

  create_table "skills_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "skill_id"
    t.index ["skill_id"], name: "index_skills_users_on_skill_id"
    t.index ["user_id"], name: "index_skills_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "join_reason"
    t.text "overview"
    t.string "location"
    t.boolean "anonymous"
    t.string "phone"
    t.string "slack_username"
    t.string "slack_userid"
    t.boolean "read_manifesto"
    t.boolean "read_code_of_conduct"
    t.bigint "referer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "optin"
    t.index ["referer_id"], name: "index_users_on_referer_id"
  end

end

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

ActiveRecord::Schema.define(version: 20200501014828) do

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

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "needs_categories", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "skill_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "lead_ids", default: [], array: true
    t.string "website"
    t.string "slack_channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "active_contributors"
    t.text "attachments"
    t.text "full_release_features"
    t.text "mission_accomplished"
    t.text "needs_pain_points_narrative"
    t.string "org_structure"
    t.datetime "project_created"
    t.string "project_mgmt_url"
    t.string "repository"
    t.string "software_license_url"
    t.string "values_screening"
    t.string "working_doc"
    t.string "business_models", default: [], array: true
    t.string "legal_structures", default: [], array: true
    t.string "oss_license_types", default: [], array: true
    t.integer "progcode_coordinator_ids", default: [], array: true
    t.string "project_applications", default: [], array: true
    t.string "progcode_github_project_link"
    t.boolean "mission_aligned"
    t.string "flags", default: [], array: true
    t.string "master_channel_list", default: [], array: true
    t.string "status", default: [], array: true
    t.string "slack_channel_id"
    t.string "airtable_id"
    t.index ["airtable_id"], name: "index_projects_on_airtable_id", unique: true
    t.index ["lead_ids"], name: "index_projects_on_lead_ids"
  end

  create_table "projects_skills", id: false, force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "skill_id"
    t.index ["project_id"], name: "index_projects_skills_on_project_id"
    t.index ["skill_id"], name: "index_projects_skills_on_skill_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "tech", default: true
  end

  create_table "skills_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "skill_id"
    t.index ["skill_id"], name: "index_skills_users_on_skill_id"
    t.index ["user_id"], name: "index_skills_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
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
    t.boolean "optin", default: true
    t.text "hear_about_us"
    t.text "verification_urls"
    t.boolean "is_approved"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.string "gender_pronouns"
    t.text "additional_info"
    t.string "airtable_id"
    t.string "secure_token"
    t.index ["airtable_id"], name: "index_users_on_airtable_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["referer_id"], name: "index_users_on_referer_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["secure_token"], name: "index_users_on_secure_token", unique: true
  end

  create_table "volunteerings", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.string "state"
    t.index ["project_id"], name: "index_volunteerings_on_project_id"
    t.index ["user_id"], name: "index_volunteerings_on_user_id"
  end

end

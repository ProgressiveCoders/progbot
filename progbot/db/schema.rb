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

ActiveRecord::Schema.define(version: 20171221041249) do

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.text "description"
    t.integer "lead_id"
    t.string "website"
    t.string "slack_channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_projects_on_lead_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "read_manifesto"
    t.boolean "read_code_of_conduct"
    t.integer "referer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referer_id"], name: "index_users_on_referer_id"
  end

end

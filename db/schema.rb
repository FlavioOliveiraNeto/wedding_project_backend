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

ActiveRecord::Schema[8.1].define(version: 2026_03_03_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "gift_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.bigint "gift_id", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_id"], name: "index_gift_selections_on_gift_id", unique: true
  end

  create_table "gifts", force: :cascade do |t|
    t.string "category", default: "outro", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10, scale: 2
    t.index ["category"], name: "index_gifts_on_category"
  end

  create_table "guests", force: :cascade do |t|
    t.integer "companions_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.text "message"
    t.string "phone", null: false
    t.bigint "principal_id"
    t.integer "rsvp_status", default: 0, null: false
    t.string "rsvp_token"
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_guests_on_full_name"
    t.index ["phone"], name: "index_guests_on_phone", unique: true
    t.index ["principal_id"], name: "index_guests_on_principal_id"
    t.index ["rsvp_token"], name: "index_guests_on_rsvp_token", unique: true
  end

  add_foreign_key "gift_selections", "gifts"
  add_foreign_key "guests", "guests", column: "principal_id"
end

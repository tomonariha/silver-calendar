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

ActiveRecord::Schema[7.0].define(version: 2023_07_18_020211) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendars", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "year", null: false
    t.string "google_calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "year"], name: "index_calendars_on_user_id_and_year", unique: true
  end

  create_table "days", force: :cascade do |t|
    t.bigint "calendar_id", null: false
    t.date "date", null: false
    t.string "schedule", default: "None"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_days_on_calendar_id"
  end

  create_table "settings", force: :cascade do |t|
    t.bigint "calendar_id", null: false
    t.date "period_start_at"
    t.date "period_end_at"
    t.integer "total_working_days"
    t.integer "minimum_working_day_of_a_week"
    t.integer "minimum_days_off_of_a_week"
    t.string "schedule_of_sunday"
    t.string "schedule_of_monday"
    t.string "schedule_of_tuesday"
    t.string "schedule_of_wednesday"
    t.string "schedule_of_thursday"
    t.string "schedule_of_friday"
    t.string "schedule_of_saturday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_settings_on_calendar_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.integer "morning_start_hour", default: 8
    t.integer "morning_start_minit", default: 0
    t.integer "morning_end_hour", default: 12
    t.integer "morning_end_minit", default: 0
    t.integer "after_noon_start_hour", default: 13
    t.integer "after_noon_start_minit", default: 0
    t.integer "after_noon_end_hour", default: 17
    t.integer "after_noon_end_minit", default: 0
    t.integer "full_time_start_hour", default: 8
    t.integer "full_time_start_minit", default: 0
    t.integer "full_time_end_hour", default: 17
    t.integer "full_time_end_minit", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end

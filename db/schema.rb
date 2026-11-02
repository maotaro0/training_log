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

ActiveRecord::Schema[8.1].define(version: 2026_11_03_001000) do
  create_table "exercises", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["name"], name: "index_shared_exercise_names", unique: true, where: "user_id IS NULL"
    t.index ["user_id", "name"], name: "index_exercises_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_exercises_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "monthly_goal", default: 12, null: false
    t.binary "avatar_data"
    t.string "avatar_content_type"
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "training_records", force: :cascade do |t|
    t.date "training_day"
    t.decimal "weight_kg"
    t.integer "reps"
    t.integer "set_count"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exercise_id", null: false
    t.index ["exercise_id"], name: "index_training_records_on_exercise_id"
    t.index ["user_id"], name: "index_training_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false, null: false
    t.datetime "guest_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guest", "guest_expires_at"], name: "index_users_on_guest_and_guest_expires_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workout_records", force: :cascade do |t|
    t.integer "workout_id", null: false
    t.integer "exercise_id", null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_workout_records_on_exercise_id"
    t.index ["workout_id"], name: "index_workout_records_on_workout_id"
  end

  create_table "workout_sets", force: :cascade do |t|
    t.integer "workout_record_id", null: false
    t.integer "set_number"
    t.decimal "weight_kg", precision: 6, scale: 2
    t.integer "reps"
    t.boolean "is_pr", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_record_id"], name: "index_workout_sets_on_workout_record_id"
  end

  create_table "workouts", force: :cascade do |t|
    t.date "date"
    t.text "memo"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "date", "created_at"], name: "index_workouts_on_user_id_and_date_and_created_at"
    t.index ["user_id"], name: "index_workouts_on_user_id"
  end

  add_foreign_key "exercises", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "training_records", "exercises"
  add_foreign_key "training_records", "users"
  add_foreign_key "workout_records", "exercises"
  add_foreign_key "workout_records", "workouts"
  add_foreign_key "workout_sets", "workout_records"
  add_foreign_key "workouts", "users"
end

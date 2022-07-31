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

ActiveRecord::Schema[7.0].define(version: 2022_07_31_021120) do
  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.string "cpf"
    t.string "email"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "physicians", force: :cascade do |t|
    t.string "name"
    t.string "crm_number"
    t.string "crm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_state", "crm_number"], name: "by_crm_state_number", unique: true
  end

  create_table "tests", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.string "result_range"
    t.string "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "patient_id"
    t.index ["patient_id"], name: "index_tests_on_patient_id"
  end

  add_foreign_key "tests", "patients"
end

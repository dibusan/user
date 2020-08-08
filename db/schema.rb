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

ActiveRecord::Schema.define(version: 20200801153646) do

  create_table "charges", force: :cascade do |t|
    t.integer  "amount"
    t.text     "description"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.text     "stripe_data"
    t.integer  "state",         default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "client_secret"
    t.integer  "stripe_fee"
    t.index ["from_user_id"], name: "index_charges_on_from_user_id"
    t.index ["to_user_id"], name: "index_charges_on_to_user_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "start_date"
    t.integer  "end_date"
    t.integer  "size",             default: 1
    t.integer  "reservation_type"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "coach_id"
    t.integer  "club_id"
    t.integer  "charge_id"
    t.index ["charge_id"], name: "index_reservations_on_charge_id"
    t.index ["club_id"], name: "index_reservations_on_club_id"
    t.index ["coach_id"], name: "index_reservations_on_coach_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "schedule_configs", force: :cascade do |t|
    t.integer  "interval_size_in_minutes"
    t.time     "day_start_time"
    t.time     "day_end_time"
    t.integer  "availability_per_interval"
    t.integer  "price_per_participant"
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["user_id"], name: "index_schedule_configs_on_user_id"
  end

  create_table "schedule_exceptions", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "all_day",                   default: false
    t.integer  "exception_type",            default: 0
    t.integer  "schedule_config_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "availability_per_interval"
    t.integer  "price_per_participant"
    t.index ["schedule_config_id"], name: "index_schedule_exceptions_on_schedule_config_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",              default: "", null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "name"
    t.integer  "parent_id"
    t.string   "password_digest"
    t.string   "stripe_acc_id"
    t.integer  "role"
    t.string   "stripe_customer_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end

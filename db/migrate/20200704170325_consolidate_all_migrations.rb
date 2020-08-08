class ConsolidateAllMigrations < ActiveRecord::Migration[5.0]
  def change
    create_table "reservations", force: :cascade do |t|
      t.datetime "start_date"
      t.datetime "end_date"
      t.integer  "size",             default: 1
      t.integer  "reservation_type"
      t.integer  "user_id"
      t.datetime "created_at",                   null: false
      t.datetime "updated_at",                   null: false
      t.integer  "coach_id"
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
      t.string   "email",           default: "", null: false
      t.datetime "created_at",                   null: false
      t.datetime "updated_at",                   null: false
      t.string   "name"
      t.integer  "parent_id"
      t.string   "password_digest"
      t.index ["email"], name: "index_users_on_email", unique: true
    end
  end
end

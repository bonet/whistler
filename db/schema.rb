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

ActiveRecord::Schema.define(version: 20191109071200) do

  create_table "order_transactions", force: :cascade do |t|
    t.decimal  "amount",     precision: 8, scale: 2
    t.integer  "user_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["user_id"], name: "index_order_transactions_on_user_id"
  end

  create_table "points", force: :cascade do |t|
    t.string   "type"
    t.integer  "order_transaction_id"
    t.integer  "user_id"
    t.integer  "quantity",             default: 0
    t.integer  "quantity_used",        default: 0
    t.boolean  "expired",              default: false
    t.string   "label"
    t.datetime "expire_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["label"], name: "index_points_on_label"
    t.index ["order_transaction_id"], name: "index_points_on_order_transaction_id"
    t.index ["type"], name: "index_points_on_type"
    t.index ["user_id"], name: "index_points_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.string "reward_type", null: false
    t.string "name"
  end

  create_table "user_rewards", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "reward_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reward_id"], name: "index_user_rewards_on_reward_id"
    t.index ["user_id"], name: "index_user_rewards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.date     "birthday"
    t.integer  "loyalty_tier", default: 0, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_17_163518) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "plaid_identifier"
    t.integer "user_id"
    t.string "official_name"
    t.string "account_type"
    t.string "account_sub_type"
    t.string "mask"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "institution_name"
    t.string "institution_id"
  end

  create_table "balances", force: :cascade do |t|
    t.bigint "account_id"
    t.float "amount"
    t.float "available"
    t.float "limit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_balances_on_account_id"
  end

  create_table "plaid_categories", force: :cascade do |t|
    t.jsonb "hierarchy"
    t.string "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_plaid_categories_on_category_id"
  end

  create_table "plaid_credentials", force: :cascade do |t|
    t.bigint "user_id"
    t.string "plaid_item_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_access_token"
    t.string "encrypted_access_token_iv"
    t.string "institution_name"
    t.string "institution_id"
    t.index ["encrypted_access_token_iv"], name: "index_plaid_credentials_on_encrypted_access_token_iv", unique: true
    t.index ["user_id"], name: "index_plaid_credentials_on_user_id"
  end

  create_table "plaid_responses", force: :cascade do |t|
    t.string "encrypted_response"
    t.string "encrypted_response_iv"
    t.string "endpoint"
    t.bigint "plaid_credential_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["encrypted_response_iv"], name: "index_plaid_responses_on_encrypted_response_iv"
    t.index ["plaid_credential_id"], name: "index_plaid_responses_on_plaid_credential_id"
  end

  create_table "transaction_groups", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "user_id"
    t.string "category", array: true
    t.string "category_id"
    t.string "transaction_type"
    t.string "description"
    t.float "amount"
    t.datetime "date"
    t.boolean "pending"
    t.jsonb "payment_metadata"
    t.jsonb "location_metadata"
    t.string "pending_transaction_id"
    t.string "account_owner"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "split", default: false
    t.uuid "transaction_group_uuid"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["transaction_group_uuid"], name: "index_transactions_on_transaction_group_uuid"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "plaid_responses", "plaid_credentials"
end

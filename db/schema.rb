# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150712012452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.decimal  "price",         precision: 12, scale: 3
    t.integer  "user_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "uuid"
    t.string   "slug"
    t.string   "product_image"
    t.boolean  "pending"
    t.boolean  "active"
  end

  add_index "products", ["slug"], name: "index_products_on_slug", unique: true, using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.string   "title"
    t.integer  "price"
    t.integer  "user_id"
    t.integer  "product_id"
    t.boolean  "refunded",                   default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "stripe_charge_id"
    t.integer  "merchant_id"
    t.string   "uuid"
    t.string   "product_image_file_name"
    t.string   "product_image_content_type"
    t.integer  "product_image_file_size"
    t.datetime "product_image_updated_at"
    t.string   "application_fee"
    t.string   "purchase_id"
    t.string   "status"
  end

  add_index "purchases", ["product_id"], name: "index_purchases_on_product_id", using: :btree
  add_index "purchases", ["user_id"], name: "index_purchases_on_user_id", using: :btree

  create_table "transfers", force: :cascade do |t|
    t.string   "status"
    t.integer  "amount"
    t.string   "date_created"
    t.integer  "user_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "marketplace_stripe_id"
  end

  add_index "transfers", ["user_id"], name: "index_transfers_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "card_number"
    t.string   "exp_month",                limit: 2
    t.integer  "exp_year"
    t.string   "cvc_number"
    t.string   "legal_name"
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name"
    t.string   "username"
    t.string   "role"
    t.string   "tax_id"
    t.string   "routing_number"
    t.string   "account_number"
    t.string   "stripe_recipient_id"
    t.integer  "pending_payment",                    default: 0
    t.string   "stripe_id"
    t.boolean  "recipient_created"
    t.string   "slug"
    t.string   "stripe_plan_name"
    t.string   "stripe_plan_id"
    t.string   "merchant_id"
    t.string   "business_name"
    t.string   "business_url"
    t.string   "support_email"
    t.string   "support_phone"
    t.string   "support_url"
    t.string   "statement_descriptor"
    t.string   "merchant_secret_key"
    t.string   "merchant_publishable_key"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "dob_day"
    t.string   "dob_month"
    t.string   "dob_year"
    t.string   "stripe_account_type"
    t.string   "stripe_account_id"
    t.string   "merchant_last_4"
    t.string   "marketplace_stripe_id"
    t.integer  "available_balance"
    t.string   "currency"
    t.string   "address_city"
    t.string   "address_zip"
    t.string   "address_state"
    t.string   "address_country"
    t.string   "address"
    t.text     "return_policy"
    t.string   "shipping_address"
    t.string   "country_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  add_foreign_key "products", "users"
  add_foreign_key "purchases", "products"
  add_foreign_key "purchases", "users"
  add_foreign_key "transfers", "users"
end

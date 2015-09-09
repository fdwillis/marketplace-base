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

ActiveRecord::Schema.define(version: 20150905163825) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "donation_plans", force: :cascade do |t|
    t.decimal  "amount",                 precision: 12, scale: 2
    t.string   "interval"
    t.string   "name"
    t.string   "currency",                                        default: "usd"
    t.string   "uuid"
    t.integer  "user_id"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "stripe_subscription_id"
  end

  add_index "donation_plans", ["user_id"], name: "index_donation_plans_on_user_id", using: :btree

  create_table "donations", force: :cascade do |t|
    t.string   "organization"
    t.decimal  "amount",                       precision: 12, scale: 2
    t.string   "uuid"
    t.integer  "user_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "fundraising_goal_id"
    t.string   "fundraiser_stripe_account_id"
    t.string   "subscription_id"
    t.string   "donation_type"
    t.boolean  "active"
    t.string   "stripe_subscription_id"
    t.string   "stripe_plan_name"
    t.decimal  "application_fee",              precision: 12, scale: 2
  end

  add_index "donations", ["fundraising_goal_id"], name: "index_donations_on_fundraising_goal_id", using: :btree
  add_index "donations", ["user_id"], name: "index_donations_on_user_id", using: :btree

  create_table "fundraising_goals", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.decimal  "goal_amount", precision: 12, scale: 2
    t.integer  "backers"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "uuid"
    t.string   "slug"
    t.text     "keywords"
    t.boolean  "active"
    t.string   "goal_image"
  end

  add_index "fundraising_goals", ["slug"], name: "index_fundraising_goals_on_slug", unique: true, using: :btree
  add_index "fundraising_goals", ["user_id"], name: "index_fundraising_goals_on_user_id", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.string   "title"
    t.decimal  "price",          precision: 12, scale: 2
    t.integer  "user_id"
    t.string   "product_uuid"
    t.integer  "quantity"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "order_id"
    t.string   "description"
    t.decimal  "shipping_price", precision: 12, scale: 2
    t.decimal  "total_price",    precision: 12, scale: 2
    t.string   "product_tags"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "status"
    t.string   "ship_to"
    t.string   "customer_name"
    t.string   "tracking_number"
    t.string   "shipping_option"
    t.decimal  "total_price",            precision: 12, scale: 2
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "user_id"
    t.boolean  "paid"
    t.decimal  "shipping_price",         precision: 12, scale: 2
    t.integer  "merchant_id"
    t.boolean  "refunded"
    t.string   "carrier"
    t.string   "purchase_id"
    t.string   "stripe_charge_id"
    t.string   "application_fee"
    t.string   "uuid"
    t.boolean  "active"
    t.string   "tracking_url"
    t.string   "stripe_shipping_charge"
    t.decimal  "refund_amount",          precision: 12, scale: 2, default: 0.0
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.decimal  "price",          precision: 12, scale: 2
    t.integer  "user_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "uuid"
    t.string   "slug"
    t.string   "product_image"
    t.boolean  "pending"
    t.boolean  "active"
    t.text     "description"
    t.integer  "quantity"
    t.string   "status"
    t.integer  "order_id"
    t.string   "shipping_title"
    t.decimal  "shipping_price", precision: 12, scale: 2
    t.text     "keywords"
    t.text     "product_tags"
  end

  add_index "products", ["order_id"], name: "index_products_on_order_id", using: :btree
  add_index "products", ["slug"], name: "index_products_on_slug", unique: true, using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.string   "title"
    t.integer  "price"
    t.integer  "user_id"
    t.integer  "product_id"
    t.boolean  "refunded",         default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "stripe_charge_id"
    t.integer  "merchant_id"
    t.string   "uuid"
    t.string   "application_fee"
    t.string   "purchase_id"
    t.string   "status"
    t.integer  "quantity"
    t.text     "description"
    t.string   "shipping_option"
    t.string   "ship_to"
    t.string   "tracking_number"
    t.string   "carrier"
  end

  add_index "purchases", ["product_id"], name: "index_purchases_on_product_id", using: :btree
  add_index "purchases", ["user_id"], name: "index_purchases_on_user_id", using: :btree

  create_table "refunds", force: :cascade do |t|
    t.integer  "order_id"
    t.decimal  "amount"
    t.string   "note"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "refunded"
    t.string   "uuid"
    t.string   "status"
    t.integer  "merchant_id"
    t.string   "order_uuid"
    t.decimal  "amount_issued", precision: 12, scale: 2, default: 0.0
  end

  add_index "refunds", ["order_id"], name: "index_refunds_on_order_id", using: :btree

  create_table "returned_products", force: :cascade do |t|
    t.string   "title"
    t.string   "price"
    t.string   "uuid"
    t.integer  "refund_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "note"
  end

  add_index "returned_products", ["refund_id"], name: "index_returned_products_on_refund_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

  create_table "shipping_addresses", force: :cascade do |t|
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "region"
    t.string   "zip"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shipping_addresses", ["user_id"], name: "index_shipping_addresses_on_user_id", using: :btree

  create_table "shipping_options", force: :cascade do |t|
    t.decimal  "price",      precision: 12, scale: 2
    t.string   "title"
    t.integer  "product_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "uuid"
  end

  add_index "shipping_options", ["product_id"], name: "index_shipping_options_on_product_id", using: :btree

  create_table "shipping_updates", force: :cascade do |t|
    t.string   "message"
    t.string   "checkpoint_time"
    t.string   "tag"
    t.integer  "purchase_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "order_id"
  end

  add_index "shipping_updates", ["order_id"], name: "index_shipping_updates_on_order_id", using: :btree

  create_table "stripe_customer_ids", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "business_name"
    t.string   "customer_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "customer_card"
  end

  add_index "stripe_customer_ids", ["user_id"], name: "index_stripe_customer_ids_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "team_members", force: :cascade do |t|
    t.string   "name"
    t.decimal  "percent",        precision: 12, scale: 2
    t.string   "stripe_bank_id"
    t.integer  "user_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "uuid"
    t.string   "routing_number"
    t.string   "country"
    t.string   "account_number"
    t.string   "role"
  end

  add_index "team_members", ["user_id"], name: "index_team_members_on_user_id", using: :btree

  create_table "text_lists", force: :cascade do |t|
    t.string   "phone_number"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "text_lists", ["user_id"], name: "index_text_lists_on_user_id", using: :btree

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
    t.string   "email",                                                       default: "",                                                                                                                                                                                                                                                                                  null: false
    t.string   "encrypted_password",                                          default: "",                                                                                                                                                                                                                                                                                  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                               default: 0,                                                                                                                                                                                                                                                                                   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                                                                                                                                                                                                                                                                                                                                null: false
    t.datetime "updated_at",                                                                                                                                                                                                                                                                                                                                                null: false
    t.string   "name"
    t.string   "username"
    t.string   "role"
    t.string   "tax_id"
    t.string   "routing_number"
    t.string   "account_number"
    t.string   "stripe_recipient_id"
    t.integer  "pending_payment",                                             default: 0
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
    t.text     "return_policy",                                               default: "Our policy lasts 30 days. If 30 days have gone by since your purchase, unfortunately we can’t offer you a refund or exchange.\n\nTo be eligible for a return, your item must be unused and in the same condition that you received it. It must also be in the original packaging."
    t.string   "shipping_address"
    t.string   "country_name"
    t.decimal  "tax_rate",                           precision: 12, scale: 2
    t.string   "bitly_link"
    t.string   "bank_currency"
    t.boolean  "account_approved"
    t.string   "logo"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  add_foreign_key "donation_plans", "users"
  add_foreign_key "donations", "fundraising_goals"
  add_foreign_key "donations", "users"
  add_foreign_key "fundraising_goals", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "orders"
  add_foreign_key "products", "users"
  add_foreign_key "purchases", "products"
  add_foreign_key "purchases", "users"
  add_foreign_key "refunds", "orders"
  add_foreign_key "returned_products", "refunds"
  add_foreign_key "roles", "users"
  add_foreign_key "shipping_addresses", "users"
  add_foreign_key "shipping_options", "products"
  add_foreign_key "shipping_updates", "orders"
  add_foreign_key "stripe_customer_ids", "users"
  add_foreign_key "team_members", "users"
  add_foreign_key "text_lists", "users"
  add_foreign_key "transfers", "users"
end

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

ActiveRecord::Schema.define(version: 20160603224859) do

  create_table "account_translations", force: :cascade do |t|
    t.string  "locale",               limit: 255
    t.integer "account_id",           limit: 4
    t.text    "imprint",              limit: 65535
    t.text    "payment_instructions", limit: 65535
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.string   "address",                     limit: 255
    t.string   "zip",                         limit: 255
    t.string   "city",                        limit: 255
    t.string   "country",                     limit: 255
    t.string   "phone",                       limit: 255
    t.string   "fax",                         limit: 255
    t.string   "email",                       limit: 255
    t.string   "layout_public",               limit: 255
    t.string   "layout_lodger",               limit: 255
    t.string   "suddomain",                   limit: 255
    t.string   "domain",                      limit: 255
    t.string   "general_keywords",            limit: 255
    t.string   "tax_number",                  limit: 255
    t.string   "bank_name",                   limit: 255
    t.string   "bank_account",                limit: 255
    t.string   "bank_code",                   limit: 255
    t.string   "iban",                        limit: 255
    t.string   "bic",                         limit: 255
    t.string   "google_maps_api_key",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mail_server",                 limit: 255
    t.integer  "mail_port",                   limit: 4
    t.string   "mail_hostname",               limit: 255
    t.string   "mail_user",                   limit: 255
    t.string   "mail_pass",                   limit: 255
    t.string   "public_name",                 limit: 255
    t.text     "mac_list",                    limit: 65535
    t.string   "website",                     limit: 255
    t.string   "company_address",             limit: 255
    t.string   "company_zip",                 limit: 255
    t.string   "company_city",                limit: 255
    t.string   "company_country",             limit: 255
    t.string   "company",                     limit: 255
    t.string   "token",                       limit: 255
    t.string   "bank_account_owner",          limit: 255
    t.string   "safe_code",                   limit: 255
    t.string   "creditor_id",                 limit: 255
    t.text     "routers",                     limit: 65535
    t.string   "redmine_url",                 limit: 255
    t.string   "redmine_api_token",           limit: 255
    t.text     "redmine_categories",          limit: 65535
    t.string   "ebics_host_id",               limit: 255
    t.string   "ebics_partner_id",            limit: 255
    t.string   "ebics_user_id",               limit: 255
    t.string   "ebics_url",                   limit: 255
    t.integer  "flags",                       limit: 4
    t.string   "bill_template",               limit: 255
    t.string   "contract_template",           limit: 255
    t.string   "deposits_bank_name",          limit: 255
    t.string   "deposits_iban",               limit: 255
    t.string   "deposits_bic",                limit: 255
    t.string   "deposits_bank_account_owner", limit: 255
  end

  create_table "accounts_languages", id: false, force: :cascade do |t|
    t.integer "language_id", limit: 4
    t.integer "account_id",  limit: 4
  end

  create_table "assignments", force: :cascade do |t|
    t.integer  "employee_id", limit: 4
    t.integer  "account_id",  limit: 4
    t.string   "role",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_file_size",   limit: 4
    t.string   "document_file_name",   limit: 255
    t.string   "document_file_type",   limit: 255
    t.datetime "document_updated_at"
    t.string   "document_fingerprint", limit: 255
    t.integer  "attachable_id",        limit: 4
    t.string   "attachable_type",      limit: 255
    t.string   "title",                limit: 255
    t.boolean  "draft",                limit: 1
    t.string   "document_type",        limit: 255
    t.boolean  "needs_signature",      limit: 1
  end

  create_table "billing_cycles", force: :cascade do |t|
    t.string   "note",       limit: 255
    t.integer  "month",      limit: 4
    t.integer  "year",       limit: 4
    t.integer  "account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_items", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "number",          limit: 255
    t.text     "description",     limit: 65535
    t.string   "billing_account", limit: 255
    t.integer  "price_in_cents",  limit: 4
    t.integer  "flags",           limit: 4
    t.integer  "account_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_orders", force: :cascade do |t|
    t.integer  "ebics_order_id", limit: 4
    t.integer  "flags",          limit: 4
    t.integer  "account_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "billable_type",  limit: 255
    t.integer  "billable_id",    limit: 4
  end

  create_table "channels", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "account_id",     limit: 4
    t.integer "relatable_id",   limit: 4
    t.string  "relatable_type", limit: 255
  end

  create_table "comments", force: :cascade do |t|
    t.text     "comment",          limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "employee_id",      limit: 4
    t.integer  "account_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["employee_id"], name: "index_comments_on_employee_id", using: :btree

  create_table "container_item_translations", force: :cascade do |t|
    t.string  "locale",            limit: 255
    t.integer "container_item_id", limit: 4
    t.text    "description",       limit: 65535
    t.string  "name",              limit: 255
  end

  create_table "container_items", force: :cascade do |t|
    t.string   "address",     limit: 255
    t.string   "zip",         limit: 255
    t.string   "city",        limit: 255
    t.string   "country",     limit: 255
    t.integer  "parent_id",   limit: 4
    t.integer  "lft",         limit: 4
    t.integer  "rgt",         limit: 4
    t.integer  "account_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "lat",                       precision: 15, scale: 10
    t.decimal  "lng",                       precision: 15, scale: 10
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
  end

  create_table "containers_attributes", id: false, force: :cascade do |t|
    t.integer "container_item_id",      limit: 4
    t.integer "item_type_attribute_id", limit: 4
  end

  create_table "contract_billing_items", force: :cascade do |t|
    t.integer  "contract_id",     limit: 4
    t.integer  "billing_item_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_billing_items", ["billing_item_id"], name: "index_contract_billing_items_on_billing_item_id", using: :btree
  add_index "contract_billing_items", ["contract_id"], name: "index_contract_billing_items_on_contract_id", using: :btree

  create_table "contracts", force: :cascade do |t|
    t.string   "number",             limit: 255
    t.string   "origin",             limit: 255
    t.string   "state",              limit: 255
    t.integer  "price_in_cents",     limit: 4
    t.integer  "deposit_in_cents",   limit: 4
    t.integer  "extras_in_cents",    limit: 4
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "user_id",            limit: 4
    t.integer  "rentable_item_id",   limit: 4
    t.integer  "account_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "internet",           limit: 1
    t.integer  "flags",              limit: 4
    t.string   "next_mandate_state", limit: 255, default: "FRST"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "employees", force: :cascade do |t|
    t.string   "firstname",              limit: 255
    t.string   "lastname",               limit: 255
    t.string   "address",                limit: 255
    t.string   "zip",                    limit: 255
    t.string   "city",                   limit: 255
    t.string   "country",                limit: 255
    t.string   "phone",                  limit: 255
    t.string   "mobile",                 limit: 255
    t.string   "fax",                    limit: 255
    t.string   "bank_name",              limit: 255
    t.string   "bank_account_number",    limit: 255
    t.string   "bank_code",              limit: 255
    t.string   "iban",                   limit: 255
    t.string   "bic",                    limit: 255
    t.boolean  "direct_debit",           limit: 1
    t.date     "birthdate"
    t.string   "email",                  limit: 255,             null: false
    t.string   "encrypted_password",     limit: 40,              null: false
    t.string   "password_salt",          limit: 255,             null: false
    t.string   "reset_password_token",   limit: 255
    t.string   "remember_token",         limit: 20
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0
    t.string   "unlock_token",           limit: 20
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reset_password_sent_at"
  end

  create_table "events", force: :cascade do |t|
    t.string   "type",             limit: 255
    t.datetime "from"
    t.datetime "till"
    t.text     "notes",            limit: 65535
    t.string   "title",            limit: 255
    t.integer  "schedulable_id",   limit: 4
    t.string   "schedulable_type", limit: 255
    t.integer  "owner_id",         limit: 4
    t.string   "owner_type",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "floor_plan_translations", force: :cascade do |t|
    t.string  "locale",        limit: 255
    t.integer "floor_plan_id", limit: 4
    t.string  "title",         limit: 255
  end

  create_table "floor_plans", force: :cascade do |t|
    t.string   "plan_file_name",    limit: 255
    t.string   "plan_content_type", limit: 255
    t.integer  "plan_file_size",    limit: 4
    t.integer  "account_id",        limit: 4
    t.integer  "container_item_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forderungen", primary_key: "receivable_id", force: :cascade do |t|
    t.string  "beleg_prefix",     limit: 6, null: false
    t.integer "beleg_suffix",     limit: 2, null: false
    t.boolean "exportiert_MFV",   limit: 1, null: false
    t.integer "buchung_nr",       limit: 4, null: false
    t.boolean "exportiert_HASPA", limit: 1, null: false
    t.integer "bezahlt_cent",     limit: 4, null: false
  end

  add_index "forderungen", ["beleg_prefix"], name: "prefix", using: :btree

  create_table "image_translations", force: :cascade do |t|
    t.string  "locale",   limit: 255
    t.integer "image_id", limit: 4
    t.string  "title",    limit: 255
  end

  create_table "images", force: :cascade do |t|
    t.string   "image_file_name",       limit: 255
    t.string   "image_content_type",    limit: 255
    t.integer  "image_file_size",       limit: 4
    t.integer  "attachable_image_id",   limit: 4
    t.string   "attachable_image_type", limit: 255
    t.integer  "account_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "presentation_order",    limit: 4
  end

  create_table "item_type_attribute_translations", force: :cascade do |t|
    t.integer "item_type_attribute_id", limit: 4
    t.string  "locale",                 limit: 255
    t.string  "value",                  limit: 255
  end

  create_table "item_type_attributes", force: :cascade do |t|
    t.integer "item_type_id", limit: 4
    t.string  "value",        limit: 255
  end

  create_table "item_type_translations", force: :cascade do |t|
    t.string  "locale",       limit: 255
    t.integer "item_type_id", limit: 4
    t.string  "name",         limit: 255
  end

  create_table "item_types", force: :cascade do |t|
    t.integer  "typeable_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lan_devices", force: :cascade do |t|
    t.string   "mac",        limit: 255
    t.string   "ip",         limit: 255
    t.string   "identifier", limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", limit: 4
  end

  create_table "language_translations", force: :cascade do |t|
    t.string  "locale",      limit: 255
    t.integer "language_id", limit: 4
    t.string  "name",        limit: 255
  end

  create_table "languages", force: :cascade do |t|
    t.string   "locale_string", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailer", force: :cascade do |t|
    t.string "type",     limit: 25,    null: false
    t.string "language", limit: 2,     null: false
    t.string "from",     limit: 25,    null: false
    t.string "subject",  limit: 255,   null: false
    t.text   "body",     limit: 65535, null: false
  end

  create_table "manage_billing_items", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "price_in_cents", limit: 4
    t.integer  "flags",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "text",        limit: 65535
    t.integer  "subject_id",  limit: 4
    t.integer  "author_id",   limit: 4
    t.string   "author_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "newsletters", force: :cascade do |t|
    t.string   "subject",    limit: 255
    t.text     "body",       limit: 65535
    t.boolean  "draft",      limit: 1
    t.datetime "sent_at"
    t.integer  "account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_translations", force: :cascade do |t|
    t.integer "page_id",    limit: 4
    t.string  "locale",     limit: 255
    t.string  "title",      limit: 255
    t.string  "menu_title", limit: 255
    t.string  "keywords",   limit: 255
    t.text    "body",       limit: 65535
  end

  create_table "pages", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.boolean  "main_menu",  limit: 1
    t.boolean  "homepage",   limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "amount_in_cents", limit: 4
    t.string   "name",            limit: 255
    t.integer  "receivable_id",   limit: 4
    t.datetime "paid_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contract_id",     limit: 4
  end

  add_index "payments", ["contract_id"], name: "index_payments_on_contract_id", using: :btree
  add_index "payments", ["receivable_id"], name: "index_payments_on_receivable_id", using: :btree

  create_table "public_areas", force: :cascade do |t|
    t.string  "name",              limit: 255
    t.integer "account_id",        limit: 4
    t.integer "container_item_id", limit: 4
  end

  create_table "receivables", force: :cascade do |t|
    t.string   "text",             limit: 255
    t.date     "due_since"
    t.date     "payed_on"
    t.integer  "account_id",       limit: 4
    t.integer  "contract_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount",           limit: 24
    t.boolean  "direct_debit",     limit: 1
    t.boolean  "exported",         limit: 1
    t.integer  "billing_cycle_id", limit: 4
    t.string   "mandate_state",    limit: 255
    t.integer  "billing_order_id", limit: 4
    t.datetime "failed_on"
    t.integer  "amount_paid",      limit: 4
    t.string   "billable_type",    limit: 255
    t.integer  "billable_id",      limit: 4
    t.boolean  "is_paid",          limit: 1
  end

  add_index "receivables", ["billable_id"], name: "index_receivables_on_billable_id", using: :btree

  create_table "rentable_item_positions", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.integer  "x",                 limit: 4
    t.integer  "y",                 limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "container_item_id", limit: 4
    t.integer  "floor_plan_id",     limit: 4
    t.integer  "account_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rentable_item_translations", force: :cascade do |t|
    t.string  "locale",           limit: 255
    t.integer "rentable_item_id", limit: 4
    t.text    "description",      limit: 65535
  end

  create_table "rentable_items", force: :cascade do |t|
    t.string   "number",             limit: 255
    t.integer  "price_in_cents",     limit: 4
    t.integer  "deposit_in_cents",   limit: 4
    t.float    "size",               limit: 24
    t.integer  "account_id",         limit: 4
    t.integer  "container_item_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "blocked",            limit: 1,     default: false
    t.boolean  "featured",           limit: 1
    t.text     "description",        limit: 65535
    t.float    "latitude",           limit: 24
    t.float    "longitude",          limit: 24
    t.string   "address",            limit: 255
    t.string   "city",               limit: 255
    t.string   "zip",                limit: 255
    t.string   "country",            limit: 255
    t.float    "room_count",         limit: 24
    t.date     "earliest_available"
    t.string   "ad_name",            limit: 255
  end

  create_table "rentables_attributes", id: false, force: :cascade do |t|
    t.integer "rentable_item_id",       limit: 4
    t.integer "item_type_attribute_id", limit: 4
  end

  create_table "requests", force: :cascade do |t|
    t.string   "firstname",        limit: 255
    t.string   "lastname",         limit: 255
    t.string   "email",            limit: 255
    t.string   "phone",            limit: 255
    t.string   "profession",       limit: 255
    t.string   "country",          limit: 255
    t.integer  "age",              limit: 4
    t.text     "message",          limit: 65535
    t.date     "start_date"
    t.date     "end_date"
    t.string   "state",            limit: 255
    t.integer  "account_id",       limit: 4
    t.integer  "rentable_item_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "id_hash",          limit: 255
    t.integer  "user_id",          limit: 4
    t.boolean  "visit",            limit: 1
    t.integer  "contract_id",      limit: 4
    t.integer  "progress",         limit: 4,     default: 0
    t.integer  "flags",            limit: 4,     default: 0, null: false
    t.integer  "accepted_by_id",   limit: 4
  end

  add_index "requests", ["accepted_by_id"], name: "index_requests_on_accepted_by_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "account_id", limit: 4
    t.string   "rules",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "room_attribute_translations", force: :cascade do |t|
    t.integer "room_attribute_id", limit: 4
    t.string  "locale",            limit: 255
    t.string  "value",             limit: 255
  end

  create_table "room_attributes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "room_attributes_rooms", id: false, force: :cascade do |t|
    t.integer "room_id",           limit: 4
    t.integer "room_attribute_id", limit: 4
  end

  create_table "room_states", force: :cascade do |t|
    t.string   "reason",                limit: 255,                null: false
    t.integer  "bed_count",             limit: 4,                  null: false
    t.boolean  "bed_ok",                limit: 1,   default: true, null: false
    t.string   "bed_comment",           limit: 255,                null: false
    t.integer  "armchair_count",        limit: 4,                  null: false
    t.boolean  "armchair_ok",           limit: 1,   default: true, null: false
    t.string   "armchair_comment",      limit: 255,                null: false
    t.integer  "mattress_count",        limit: 4,                  null: false
    t.boolean  "mattress_ok",           limit: 1,   default: true, null: false
    t.string   "mattress_comment",      limit: 255,                null: false
    t.integer  "bin_count",             limit: 4,                  null: false
    t.boolean  "bin_ok",                limit: 1,   default: true, null: false
    t.string   "bin_comment",           limit: 255,                null: false
    t.integer  "closet_count",          limit: 4,                  null: false
    t.boolean  "closet_ok",             limit: 1,   default: true, null: false
    t.string   "closet_comment",        limit: 255,                null: false
    t.integer  "dresser_count",         limit: 4,                  null: false
    t.boolean  "dresser_ok",            limit: 1,   default: true, null: false
    t.string   "dresser_comment",       limit: 255,                null: false
    t.integer  "floor_lamp_count",      limit: 4,                  null: false
    t.boolean  "floor_lamp_ok",         limit: 1,   default: true, null: false
    t.string   "floor_lamp_comment",    limit: 255,                null: false
    t.integer  "slatted_frame_count",   limit: 4,                  null: false
    t.boolean  "slatted_frame_ok",      limit: 1,   default: true, null: false
    t.string   "slatted_frame_comment", limit: 255,                null: false
    t.integer  "desk_count",            limit: 4,                  null: false
    t.boolean  "desk_ok",               limit: 1,   default: true, null: false
    t.string   "desk_comment",          limit: 255,                null: false
    t.integer  "chair_count",           limit: 4,                  null: false
    t.boolean  "chair_ok",              limit: 1,   default: true, null: false
    t.string   "chair_comment",         limit: 255,                null: false
    t.integer  "curtain_count",         limit: 4,                  null: false
    t.boolean  "curtain_ok",            limit: 1,   default: true, null: false
    t.string   "curtain_comment",       limit: 255,                null: false
    t.integer  "sofa_count",            limit: 4,                  null: false
    t.boolean  "sofa_ok",               limit: 1,   default: true, null: false
    t.string   "sofa_comment",          limit: 255,                null: false
    t.integer  "box_count",             limit: 4,                  null: false
    t.boolean  "box_ok",                limit: 1,   default: true, null: false
    t.string   "box_comment",           limit: 255,                null: false
    t.integer  "key_count",             limit: 4,                  null: false
    t.integer  "door_chip_count",       limit: 4,                  null: false
    t.string   "comment",               limit: 255
    t.integer  "account_id",            limit: 4
    t.integer  "rentable_item_id",      limit: 4
    t.integer  "user_id",               limit: 4
    t.integer  "employee_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "slugs", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "sluggable_id",   limit: 4
    t.integer  "sequence",       limit: 4,   default: 1, null: false
    t.string   "sluggable_type", limit: 40
    t.string   "scope",          limit: 40
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], name: "index_slugs_on_n_s_s_and_s", unique: true, using: :btree
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree

  create_table "stylesheets", force: :cascade do |t|
    t.text    "variables",      limit: 65535
    t.integer "themeable_id",   limit: 4
    t.string  "themeable_type", limit: 255
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "user_id",    limit: 4
    t.integer  "channel_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "account_id", limit: 4
  end

  add_index "subjects", ["account_id"], name: "index_subjects_on_account_id", using: :btree

  create_table "terms", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.text     "body",        limit: 65535
    t.integer  "account_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "company",                limit: 255
    t.string   "firstname",              limit: 255
    t.string   "lastname",               limit: 255
    t.string   "address",                limit: 255
    t.string   "zip",                    limit: 255
    t.string   "city",                   limit: 255
    t.string   "country",                limit: 255
    t.string   "phone",                  limit: 255
    t.string   "mobile",                 limit: 255
    t.string   "fax",                    limit: 255
    t.string   "bank_name",              limit: 255
    t.string   "bank_account_number",    limit: 255
    t.string   "bank_code",              limit: 255
    t.string   "iban",                   limit: 255
    t.string   "bic",                    limit: 255
    t.boolean  "direct_debit",           limit: 1
    t.date     "birthdate"
    t.string   "email",                  limit: 255,               null: false
    t.string   "encrypted_password",     limit: 40,                null: false
    t.string   "password_salt",          limit: 255,               null: false
    t.string   "reset_password_token",   limit: 255
    t.string   "remember_token",         limit: 20
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "failed_attempts",        limit: 4,     default: 0
    t.string   "unlock_token",           limit: 20
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",             limit: 4
    t.date     "rented_until"
    t.string   "room_number",            limit: 255
    t.boolean  "active",                 limit: 1
    t.string   "bank_account_holder",    limit: 255
    t.integer  "kreditoren_nr",          limit: 4
    t.integer  "debitoren_nr",           limit: 4
    t.string   "anrede",                 limit: 255
    t.datetime "mandate_changed"
    t.datetime "reset_password_sent_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.text     "signature_data",         limit: 65535
    t.text     "rsa",                    limit: 65535
  end

  create_table "users_test", force: :cascade do |t|
    t.string   "company",              limit: 255
    t.string   "firstname",            limit: 255
    t.string   "lastname",             limit: 255
    t.string   "address",              limit: 255
    t.string   "zip",                  limit: 255
    t.string   "city",                 limit: 255
    t.string   "country",              limit: 255
    t.string   "phone",                limit: 255
    t.string   "mobile",               limit: 255
    t.string   "fax",                  limit: 255
    t.string   "bank_name",            limit: 255
    t.string   "bank_account_number",  limit: 255
    t.string   "bank_code",            limit: 255
    t.string   "iban",                 limit: 255
    t.string   "bic",                  limit: 255
    t.boolean  "direct_debit",         limit: 1
    t.date     "birthdate"
    t.string   "email",                limit: 255,             null: false
    t.string   "encrypted_password",   limit: 40,              null: false
    t.string   "password_salt",        limit: 255,             null: false
    t.string   "reset_password_token", limit: 20
    t.string   "remember_token",       limit: 20
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        limit: 4
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",   limit: 255
    t.string   "last_sign_in_ip",      limit: 255
    t.integer  "failed_attempts",      limit: 4,   default: 0
    t.string   "unlock_token",         limit: 20
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",           limit: 4
    t.date     "rented_until"
    t.string   "room_number",          limit: 255
    t.boolean  "active",               limit: 1
    t.string   "bank_account_holder",  limit: 255
    t.integer  "kreditoren_nr",        limit: 4
    t.integer  "debitoren_nr",         limit: 4
    t.string   "anrede",               limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end

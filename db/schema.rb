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

ActiveRecord::Schema.define(version: 20180809074729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.text     "line_1"
    t.text     "line_2"
    t.text     "line_3"
    t.string   "city"
    t.string   "state"
    t.bigint   "pincode"
    t.integer  "name"
    t.boolean  "address_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mobile"
    t.boolean  "default"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id", using: :btree
  end

  create_table "aggregation_rounds", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "qty_limit"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "status"
    t.index ["product_id"], name: "index_aggregation_rounds_on_product_id", using: :btree
  end

  create_table "api_keys", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.boolean  "active"
    t.string   "access_token"
    t.datetime "expires_at"
    t.string   "supplier_email"
    t.index ["user_id"], name: "index_api_keys_on_user_id", using: :btree
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "account_number"
    t.string   "routing_number"
    t.string   "name"
    t.string   "type"
    t.string   "stripe_customer_token"
    t.integer  "user_id"
    t.string   "stripe_user_id"
    t.index ["user_id"], name: "index_bank_accounts_on_user_id", using: :btree
  end

  create_table "banners", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link"
    t.string   "button_text"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "quantity",    default: 1
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "product_id"
    t.integer  "price_cents", default: 0
    t.integer  "provider_id"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
    t.index ["provider_id"], name: "index_cart_items_on_provider_id", using: :btree
  end

  create_table "carts", force: :cascade do |t|
    t.boolean  "active",      default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
    t.integer  "provider_id"
    t.index ["provider_id"], name: "index_carts_on_provider_id", using: :btree
    t.index ["user_id"], name: "index_carts_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "collection_inventories", force: :cascade do |t|
    t.integer  "collection_id"
    t.integer  "inventory_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["collection_id"], name: "index_collection_inventories_on_collection_id", using: :btree
    t.index ["inventory_id"], name: "index_collection_inventories_on_inventory_id", using: :btree
  end

  create_table "collections", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "picture_id"
    t.integer  "category_id"
    t.index ["category_id"], name: "index_collections_on_category_id", using: :btree
    t.index ["picture_id"], name: "index_collections_on_picture_id", using: :btree
    t.index ["user_id"], name: "index_collections_on_user_id", using: :btree
  end

  create_table "companies", id: :bigserial, force: :cascade do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "contact_number"
    t.string   "landline_number"
    t.string   "vendor_code"
    t.string   "gstin"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "customer_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_customer_groups_on_group_id", using: :btree
    t.index ["user_id"], name: "index_customer_groups_on_user_id", using: :btree
  end

  create_table "demands", force: :cascade do |t|
    t.integer  "qty"
    t.integer  "aggregation_round_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "price_cents",          default: 0,     null: false
    t.string   "price_currency",       default: "USD", null: false
    t.index ["aggregation_round_id"], name: "index_demands_on_aggregation_round_id", using: :btree
  end

  create_table "drivers", id: :bigserial, force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mobile_number"
    t.string   "alternate_number"
    t.string   "license_number"
    t.string   "license_expiry_date"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "group_products", force: :cascade do |t|
    t.integer  "price_cents"
    t.string   "sku"
    t.integer  "product_id"
    t.integer  "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["group_id"], name: "index_group_products_on_group_id", using: :btree
    t.index ["product_id"], name: "index_group_products_on_product_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "provider_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["provider_id"], name: "index_groups_on_provider_id", using: :btree
  end

  create_table "inventories", force: :cascade do |t|
    t.integer  "quantity"
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "capacity",       default: 1000
    t.integer  "threshold"
    t.string   "description"
    t.string   "name"
    t.string   "barcode"
    t.integer  "picture_id"
    t.string   "sku"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "USD", null: false
    t.float    "discount",       default: 0.0
    t.boolean  "is_invoice",     default: false
    t.index ["picture_id"], name: "index_inventories_on_picture_id", using: :btree
    t.index ["product_id"], name: "index_inventories_on_product_id", using: :btree
    t.index ["user_id"], name: "index_inventories_on_user_id", using: :btree
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "price_cents"
    t.integer  "quantity"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "provider_id"
    t.integer  "status",      default: 0
    t.index ["order_id"], name: "index_order_items_on_order_id", using: :btree
    t.index ["product_id"], name: "index_order_items_on_product_id", using: :btree
    t.index ["provider_id"], name: "index_order_items_on_provider_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mobile_number"
    t.integer  "status"
    t.jsonb    "payment_details"
    t.integer  "total_price_cents"
    t.datetime "order_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.float    "sales_tax",              default: 0.0
    t.integer  "shipping_charges_cents", default: 0
    t.string   "other_charges_name"
    t.integer  "other_charges_cents",    default: 0
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title"
    t.string   "content"
    t.string   "url"
    t.integer  "provider_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["provider_id"], name: "index_pages_on_provider_id", using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.text     "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "picturable_id"
    t.string   "picturable_type"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "picture_file_file_name"
    t.string   "picture_file_content_type"
    t.integer  "picture_file_file_size"
    t.datetime "picture_file_updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "category_id"
    t.string   "sku"
    t.integer  "manufacturer_id"
    t.integer  "vendor_id"
    t.boolean  "is_aggregatable",          default: false
    t.integer  "price_cents",              default: 0,     null: false
    t.string   "price_currency",           default: "USD", null: false
    t.string   "short_description"
    t.string   "delivery_time"
    t.string   "SKU"
    t.string   "barcode"
    t.string   "amazon_id"
    t.integer  "user_id"
    t.integer  "provider_id"
    t.string   "unit"
    t.boolean  "storefront_option",        default: true
    t.string   "brand"
    t.jsonb    "technical_specifications"
    t.integer  "supplier_category_id"
    t.integer  "sub_category_id"
    t.integer  "inventory_count",          default: 0
    t.boolean  "inventory_policy"
    t.string   "barcode_value"
    t.jsonb    "meta"
    t.index ["manufacturer_id"], name: "index_products_on_manufacturer_id", using: :btree
    t.index ["provider_id"], name: "index_products_on_provider_id", using: :btree
    t.index ["sub_category_id"], name: "index_products_on_sub_category_id", using: :btree
    t.index ["supplier_category_id"], name: "index_products_on_supplier_category_id", using: :btree
    t.index ["user_id"], name: "index_products_on_user_id", using: :btree
    t.index ["vendor_id"], name: "index_products_on_vendor_id", using: :btree
  end

  create_table "provider_credentials", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "provider_id"
    t.string   "username"
    t.text     "password"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "encrypted_password"
    t.string   "encrypted_password_iv"
    t.index ["provider_id"], name: "index_provider_credentials_on_provider_id", using: :btree
    t.index ["user_id"], name: "index_provider_credentials_on_user_id", using: :btree
  end

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "login_required",     default: true
    t.integer  "expiry_seconds",     default: 86400
    t.string   "cart_url"
    t.integer  "user_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "email"
    t.string   "slug"
    t.string   "slug_name"
    t.jsonb    "meta"
    t.index ["user_id"], name: "index_providers_on_user_id", using: :btree
  end

  create_table "quote_requests", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "mobile_number"
    t.integer  "category_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "upload_file_file_name"
    t.string   "upload_file_content_type"
    t.integer  "upload_file_file_size"
    t.datetime "upload_file_updated_at"
    t.string   "category_ids",             default: [],              array: true
    t.index ["category_id"], name: "index_quote_requests_on_category_id", using: :btree
  end

  create_table "request_quotes", force: :cascade do |t|
    t.string   "product_name"
    t.string   "item_number"
    t.string   "description"
    t.string   "quantity"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.integer  "product_id"
    t.integer  "provider_id"
    t.index ["product_id"], name: "index_request_quotes_on_product_id", using: :btree
    t.index ["provider_id"], name: "index_request_quotes_on_provider_id", using: :btree
    t.index ["user_id"], name: "index_request_quotes_on_user_id", using: :btree
  end

  create_table "scrap_results", force: :cascade do |t|
    t.integer  "count"
    t.text     "result"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "product_id"
    t.integer  "provider_id"
    t.string   "status",      default: "ongoing"
    t.index ["product_id"], name: "index_scrap_results_on_product_id", using: :btree
    t.index ["provider_id"], name: "index_scrap_results_on_provider_id", using: :btree
    t.index ["user_id"], name: "index_scrap_results_on_user_id", using: :btree
  end

  create_table "sub_categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.index ["category_id"], name: "index_sub_categories_on_category_id", using: :btree
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "stripe_customer_token"
    t.integer  "user_id"
    t.string   "stripe_user_id",        null: false
    t.string   "last4"
    t.string   "exp_year"
    t.string   "exp_month"
    t.index ["user_id"], name: "index_subscriptions_on_user_id", using: :btree
  end

  create_table "supplier_bids", force: :cascade do |t|
    t.integer  "supplier_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "price_cents",      default: 0,          null: false
    t.string   "price_currency",   default: "USD",      null: false
    t.integer  "request_quote_id"
    t.string   "status",           default: "received"
    t.string   "notes"
    t.integer  "product_id"
    t.index ["product_id"], name: "index_supplier_bids_on_product_id", using: :btree
    t.index ["supplier_id"], name: "index_supplier_bids_on_supplier_id", using: :btree
  end

  create_table "supplier_categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "parent_id"
    t.integer  "provider_id"
    t.index ["provider_id"], name: "index_supplier_categories_on_provider_id", using: :btree
  end

  create_table "user_provider_mappings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "provider_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["provider_id"], name: "index_user_provider_mappings_on_provider_id", using: :btree
    t.index ["user_id"], name: "index_user_provider_mappings_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mobile"
    t.integer  "sex"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "email",                   default: "",    null: false
    t.string   "encrypted_password",      default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",       default: 0
    t.boolean  "admin",                   default: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "company"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "location"
    t.boolean  "is_invoice",              default: false
    t.text     "stripe_account_status",   default: "{}"
    t.string   "stripe_account_type"
    t.string   "publishable_key"
    t.string   "secret_key"
    t.string   "stripe_user_id"
    t.string   "currency"
    t.string   "customer_id"
    t.integer  "shipping_choice"
    t.string   "shipping_account_number"
    t.string   "shippers_name"
    t.integer  "provider_id"
    t.string   "store_name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["provider_id"], name: "index_users_on_provider_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "aggregation_rounds", "products"
  add_foreign_key "api_keys", "users"
  add_foreign_key "bank_accounts", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "providers"
  add_foreign_key "carts", "providers"
  add_foreign_key "carts", "users"
  add_foreign_key "collection_inventories", "collections", on_delete: :cascade
  add_foreign_key "collection_inventories", "inventories", on_delete: :cascade
  add_foreign_key "collections", "categories"
  add_foreign_key "collections", "pictures"
  add_foreign_key "collections", "users"
  add_foreign_key "customer_groups", "groups"
  add_foreign_key "customer_groups", "users"
  add_foreign_key "demands", "aggregation_rounds"
  add_foreign_key "group_products", "groups"
  add_foreign_key "group_products", "products"
  add_foreign_key "groups", "providers"
  add_foreign_key "inventories", "pictures"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "providers"
  add_foreign_key "orders", "users"
  add_foreign_key "pages", "providers"
  add_foreign_key "products", "manufacturers"
  add_foreign_key "products", "providers"
  add_foreign_key "products", "sub_categories"
  add_foreign_key "products", "supplier_categories"
  add_foreign_key "products", "users"
  add_foreign_key "products", "vendors"
  add_foreign_key "provider_credentials", "providers"
  add_foreign_key "provider_credentials", "users"
  add_foreign_key "providers", "users"
  add_foreign_key "quote_requests", "categories"
  add_foreign_key "request_quotes", "products"
  add_foreign_key "request_quotes", "providers"
  add_foreign_key "request_quotes", "users"
  add_foreign_key "scrap_results", "products"
  add_foreign_key "scrap_results", "providers"
  add_foreign_key "scrap_results", "users"
  add_foreign_key "sub_categories", "categories"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "supplier_bids", "products"
  add_foreign_key "supplier_categories", "providers"
  add_foreign_key "user_provider_mappings", "providers"
  add_foreign_key "user_provider_mappings", "users"
  add_foreign_key "users", "providers"
end

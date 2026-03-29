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

ActiveRecord::Schema[8.1].define(version: 2026_03_29_180214) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "campaign_products", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "product_id"], name: "index_campaign_products_on_campaign_id_and_product_id", unique: true
    t.index ["campaign_id"], name: "index_campaign_products_on_campaign_id"
    t.index ["product_id"], name: "index_campaign_products_on_product_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "discount_percent", default: 0, null: false
    t.datetime "ends_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_campaigns_on_slug", unique: true
    t.index ["starts_at", "ends_at"], name: "index_campaigns_on_starts_at_and_ends_at"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "flag_products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.integer "flag_type", null: false
    t.integer "original_amount_cents"
    t.string "original_amount_currency", default: "THB", null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["flag_type", "position"], name: "index_flag_products_on_flag_type_and_position"
    t.index ["product_id", "flag_type"], name: "index_flag_products_on_product_id_and_flag_type", unique: true
    t.index ["product_id"], name: "index_flag_products_on_product_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "THB", null: false
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.string "sku", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "order_store_payouts", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "THB", null: false
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "seller_store_id", null: false
    t.string "status", default: "pending", null: false
    t.string "transfer_id"
    t.datetime "transferred_at"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_store_payouts_on_order_id"
    t.index ["seller_store_id"], name: "index_order_store_payouts_on_seller_store_id"
    t.index ["transfer_id"], name: "index_order_store_payouts_on_transfer_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "omise_charge_id"
    t.string "omise_source_id"
    t.datetime "paid_at"
    t.integer "platform_fee_cents", default: 0, null: false
    t.string "platform_fee_currency", default: "THB", null: false
    t.integer "shipping_cents", default: 0, null: false
    t.string "shipping_currency", default: "THB", null: false
    t.string "status", default: "pending", null: false
    t.integer "total_amount_cents", default: 0, null: false
    t.string "total_amount_currency", default: "THB", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["omise_charge_id"], name: "index_orders_on_omise_charge_id", unique: true
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_bundle_items", force: :cascade do |t|
    t.bigint "bundle_product_id", null: false
    t.bigint "component_product_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.text "usage_instructions"
    t.index ["bundle_product_id", "position"], name: "index_product_bundle_items_on_bundle_product_id_and_position"
    t.index ["bundle_product_id"], name: "index_product_bundle_items_on_bundle_product_id"
    t.index ["component_product_id"], name: "index_product_bundle_items_on_component_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "THB", null: false
    t.string "bundle_set_type_key"
    t.string "category_key"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "effect"
    t.string "kind", default: "standard", null: false
    t.integer "promotion_cents", default: 0, null: false
    t.string "promotion_currency", default: "THB", null: false
    t.datetime "promotion_ends_at"
    t.datetime "promotion_starts_at"
    t.bigint "seller_store_id", null: false
    t.string "skin_concern_key"
    t.string "skin_concern_keys"
    t.string "sku", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.text "usage"
    t.integer "volume"
    t.string "volume_unit"
    t.index ["category_key"], name: "index_products_on_category_key"
    t.index ["kind"], name: "index_products_on_kind"
    t.index ["seller_store_id"], name: "index_products_on_seller_store_id"
    t.index ["skin_concern_key"], name: "index_products_on_skin_concern_key"
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "seller_stores", force: :cascade do |t|
    t.string "bank_code"
    t.string "bank_name"
    t.string "bank_number"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location", null: false
    t.string "name", null: false
    t.string "omise_recipient_id"
    t.bigint "seller_user_id", null: false
    t.string "status", default: "inactive", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_seller_stores_on_name", unique: true
    t.index ["omise_recipient_id"], name: "index_seller_stores_on_omise_recipient_id"
    t.index ["seller_user_id"], name: "index_seller_stores_on_seller_user_id", unique: true
  end

  create_table "seller_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_seller_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_seller_users_on_reset_password_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "location"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campaign_products", "campaigns"
  add_foreign_key "campaign_products", "products"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "flag_products", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_store_payouts", "orders"
  add_foreign_key "order_store_payouts", "seller_stores"
  add_foreign_key "orders", "users"
  add_foreign_key "product_bundle_items", "products", column: "bundle_product_id"
  add_foreign_key "product_bundle_items", "products", column: "component_product_id"
  add_foreign_key "products", "seller_stores"
  add_foreign_key "seller_stores", "seller_users"
end

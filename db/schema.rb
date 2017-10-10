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

ActiveRecord::Schema.define(version: 20171010102659) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "images", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mockup_groups", force: :cascade do |t|
    t.integer "mockup_id", limit: 8
    t.string "variant_ids"
    t.string "placement"
    t.string "mockup_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mockup_id"], name: "index_mockup_groups_on_mockup_id"
  end

  create_table "mockup_images", force: :cascade do |t|
    t.integer "mockup_id", limit: 8
    t.string "variant_ids"
    t.string "image"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mockup_id"], name: "index_mockup_images_on_mockup_id"
  end

  create_table "mockups", force: :cascade do |t|
    t.string "mockup_url"
    t.string "placement"
    t.string "variant_ids"
    t.string "thumb_url"
    t.string "product_url"
    t.string "image_url"
    t.integer "printful_id", limit: 8
    t.integer "shopify_id", limit: 8
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "job_id"
    t.string "order_status_url"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "template_data", force: :cascade do |t|
    t.integer "product_id", limit: 8
    t.string "title"
    t.string "group"
    t.integer "width"
    t.integer "height"
    t.string "placement"
    t.string "hashdata"
    t.integer "area_width"
    t.integer "area_height"
    t.integer "area_x"
    t.integer "area_y"
    t.integer "safe_area_width"
    t.integer "safe_area_height"
    t.integer "safe_area_x"
    t.integer "safe_area_y"
    t.integer "order"
    t.string "file_background"
    t.string "file_overlay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_template_data_on_product_id"
  end

  create_table "templates", force: :cascade do |t|
    t.integer "product_id", limit: 8
    t.string "title"
    t.string "group"
    t.integer "width"
    t.integer "height"
    t.string "placement"
    t.string "hash"
    t.integer "area_width"
    t.integer "area_height"
    t.integer "area_x"
    t.integer "area_y"
    t.integer "safe_area_width"
    t.integer "safe_area_height"
    t.integer "safe_area_x"
    t.integer "safe_area_y"
    t.integer "order"
    t.string "file_background"
    t.string "file_overlay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_templates_on_product_id"
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
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end

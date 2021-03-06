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

ActiveRecord::Schema.define(version: 20140712215805) do

  create_table "button_types", force: true do |t|
    t.string   "name",                        null: false
    t.string   "description", default: ""
    t.boolean  "deleted",     default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "buttons", force: true do |t|
    t.string   "name",           default: ""
    t.string   "description",    default: ""
    t.integer  "button_type_id",                 null: false
    t.integer  "display_order",  default: 0,     null: false
    t.string   "filename",       default: ""
    t.boolean  "deleted",        default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "html",           default: ""
  end

  create_table "causes", force: true do |t|
    t.string   "name",                                 null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "deleted"
    t.string   "uid",                                  null: false
    t.string   "type",                                 null: false
    t.string   "fg_uuid",                 default: ""
    t.integer  "fg_type_id"
    t.string   "alias",                   default: ""
    t.text     "abstract"
    t.integer  "ein"
    t.string   "fg_parent_uuid",          default: ""
    t.string   "address_line_1",          default: ""
    t.string   "address_line_2",          default: ""
    t.string   "address_line_3",          default: ""
    t.string   "address_line_full",       default: ""
    t.string   "city",                    default: ""
    t.string   "region",                  default: ""
    t.string   "postal_code",             default: ""
    t.string   "county",                  default: ""
    t.string   "country",                 default: ""
    t.string   "address_full",            default: ""
    t.string   "phone_number",            default: ""
    t.string   "area_code",               default: ""
    t.string   "url",                     default: ""
    t.string   "fg_category_code",        default: ""
    t.string   "fg_category_title",       default: ""
    t.string   "fg_category_description", default: ""
    t.string   "latitude",                default: ""
    t.string   "longitude",               default: ""
    t.string   "fg_revoked",              default: ""
    t.string   "fg_locale_db_id",         default: ""
  end

  add_index "causes", ["fg_uuid"], name: "index_causes_on_fg_uuid", using: :btree
  add_index "causes", ["name"], name: "index_causes_on_name", unique: true, using: :btree
  add_index "causes", ["type"], name: "index_causes_on_type", using: :btree
  add_index "causes", ["uid"], name: "index_causes_on_uid", unique: true, using: :btree

  create_table "causes_groups", id: false, force: true do |t|
    t.integer "cause_id"
    t.integer "group_id"
  end

  add_index "causes_groups", ["cause_id", "group_id"], name: "index_causes_groups_on_cause_id_and_group_id", unique: true, using: :btree

  create_table "causes_users", id: false, force: true do |t|
    t.integer "cause_id"
    t.integer "user_id"
  end

  add_index "causes_users", ["user_id", "cause_id"], name: "index_causes_users_on_user_id_and_cause_id", unique: true, using: :btree

  create_table "channels", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "awesm_id"
    t.string   "description"
    t.boolean  "deleted"
    t.boolean  "visible",                default: true
    t.boolean  "active",                 default: true
    t.string   "url_prefix",             default: ""
    t.string   "font_awesome_icon_name", default: ""
    t.integer  "display_order"
  end

  add_index "channels", ["name"], name: "index_channels_on_name", unique: true, using: :btree

  create_table "channels_promotions", id: false, force: true do |t|
    t.integer "channel_id",   null: false
    t.integer "promotion_id", null: false
  end

  add_index "channels_promotions", ["promotion_id", "channel_id"], name: "index_channels_promotions_on_promotion_id_and_channel_id", unique: true, using: :btree

  create_table "donations", force: true do |t|
    t.integer  "sale_id",                  null: false
    t.integer  "merchant_id",              null: false
    t.integer  "cause_id",                 null: false
    t.string   "chosen_by",                null: false
    t.integer  "amount_cents", default: 0, null: false
    t.boolean  "deleted"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "chooser_id"
    t.integer  "supporter_id"
    t.integer  "buyer_id"
  end

  create_table "events", force: true do |t|
    t.string   "name",        default: ""
    t.string   "description", default: ""
    t.integer  "order",       default: 0
    t.boolean  "deleted",     default: false
    t.date     "event_date",  default: '2013-11-22', null: false
    t.date     "start_date",  default: '2013-11-22', null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "group_id",                           null: false
    t.date     "end_date"
    t.string   "uid",                                null: false
  end

  create_table "lists", force: true do |t|
    t.string   "name",        default: ""
    t.string   "description", default: ""
    t.string   "type",                        null: false
    t.integer  "order",       default: 0
    t.boolean  "deleted",     default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "merchants", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "website"
    t.string   "logo_link"
    t.boolean  "deleted"
    t.integer  "promotions_count",   default: 0
    t.string   "uid"
    t.integer  "button_id"
    t.integer  "widget_position_id"
    t.integer  "auto_button_id"
  end

  add_index "merchants", ["name"], name: "index_merchants_on_name", unique: true, using: :btree
  add_index "merchants", ["uid"], name: "index_merchants_on_uid", unique: true, using: :btree

  create_table "merchants_users", id: false, force: true do |t|
    t.integer "merchant_id"
    t.integer "user_id"
  end

  add_index "merchants_users", ["user_id", "merchant_id"], name: "index_merchants_users_on_user_id_and_merchant_id", unique: true, using: :btree

  create_table "promotions", force: true do |t|
    t.string   "description",                                      default: ""
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "merchant_id"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.string   "name",                                             default: ""
    t.integer  "cause_id"
    t.integer  "merchant_pct"
    t.integer  "supporter_pct"
    t.integer  "buyer_pct"
    t.string   "landing_page",                                     default: ""
    t.boolean  "deleted"
    t.decimal  "uid",                     precision: 16, scale: 6
    t.integer  "priority"
    t.boolean  "disabled"
    t.string   "banner",                                           default: ""
    t.integer  "serves_count",                                     default: 0
    t.string   "facebook_msg",                                     default: ""
    t.string   "fb_link_label",                                    default: ""
    t.string   "fb_caption",                                       default: ""
    t.string   "fb_redirect_url",                                  default: ""
    t.string   "fb_thumb_url",                                     default: ""
    t.boolean  "disable_msg_editing"
    t.string   "twitter_msg",                                      default: ""
    t.string   "pinterest_msg",                                    default: ""
    t.string   "pin_image_url",                                    default: ""
    t.string   "pin_def_board",                                    default: ""
    t.string   "pin_thumb_url",                                    default: ""
    t.string   "linkedin_msg",                                     default: ""
    t.string   "facebook_msg_template",                            default: ""
    t.string   "twitter_msg_template",                             default: ""
    t.string   "pinterest_msg_template",                           default: ""
    t.string   "linkedin_msg_template",                            default: ""
    t.string   "email_subject_template",                           default: ""
    t.string   "email_body_template",                              default: ""
    t.string   "email_subject",                                    default: ""
    t.string   "email_body",                                       default: ""
    t.string   "googleplus_msg_template",                          default: ""
    t.string   "googleplus_msg",                                   default: ""
    t.string   "banner_template",                                  default: ""
    t.integer  "button_id",                                                     null: false
    t.integer  "widget_position_id"
    t.integer  "event_id"
    t.string   "title",                                                         null: false
    t.boolean  "unservable"
  end

  add_index "promotions", ["merchant_id"], name: "index_promotions_on_merchant_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
    t.boolean  "deleted"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", unique: true, using: :btree

  create_table "sales", force: true do |t|
    t.integer  "share_id",                       null: false
    t.integer  "amount_cents",       default: 0, null: false
    t.string   "transaction_id"
    t.boolean  "deleted"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "supporter_share_id"
  end

  create_table "serves", force: true do |t|
    t.integer  "promotion_id",                       null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "deleted"
    t.integer  "referring_share_id"
    t.boolean  "viewed",             default: false
    t.integer  "shares_count",       default: 0
    t.string   "session_id"
    t.integer  "current_cause_id"
    t.integer  "user_id"
    t.integer  "default_cause_id",                   null: false
    t.integer  "serve_count",                        null: false
    t.integer  "session_count",                      null: false
    t.integer  "referral_count",     default: 0,     null: false
  end

  add_index "serves", ["session_id"], name: "index_serves_on_session_id", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "banner_template_1"
    t.string   "banner_template_2"
    t.string   "banner_template_3"
    t.string   "banner_template_4"
    t.string   "banner_template_5"
    t.string   "banner_template_6"
    t.string   "banner_template_7"
    t.string   "banner_template_8"
    t.boolean  "deleted"
    t.string   "fb_link_label"
    t.string   "fb_caption"
    t.string   "fb_redirect_url"
    t.string   "fb_thumb_url"
    t.string   "fb_msg_template_1"
    t.string   "fb_msg_template_2"
    t.string   "fb_msg_template_3"
    t.string   "fb_msg_template_4"
    t.string   "fb_msg_template_5"
    t.string   "fb_msg_template_6"
    t.string   "fb_msg_template_7"
    t.string   "fb_msg_template_8"
    t.string   "twitter_msg_template"
    t.string   "pinterest_msg_template"
    t.string   "pin_image_url"
    t.string   "pin_def_board"
    t.string   "pin_thumb_url"
    t.string   "linkedin_msg_template"
    t.integer  "cookie_life"
    t.string   "email_subject_template"
    t.string   "email_body_template"
    t.string   "googleplus_msg_template"
  end

  create_table "shares", force: true do |t|
    t.integer  "serve_id",                    null: false
    t.integer  "channel_id",                  null: false
    t.string   "link_id",                     null: false
    t.boolean  "confirmed",   default: false
    t.boolean  "deleted"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "cause_id"
    t.integer  "sales_count", default: 0
    t.string   "post_id"
  end

  add_index "shares", ["link_id"], name: "index_shares_on_link_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "deleted"
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "invitation_created_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["number"], name: "index_versions_on_number", using: :btree
  add_index "versions", ["tag"], name: "index_versions_on_tag", using: :btree
  add_index "versions", ["user_id", "user_type"], name: "index_versions_on_user_id_and_user_type", using: :btree
  add_index "versions", ["user_name"], name: "index_versions_on_user_name", using: :btree
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type", using: :btree

end

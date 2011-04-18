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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110405072140) do

  create_table "ideas", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "reminder_date"
    t.integer  "privacy_id"
  end

  add_index "ideas", ["user_id"], :name => "index_ideas_on_user_id"

  create_table "privacies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "website"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "reminders", :force => true do |t|
    t.date     "reminder_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "idea_id"
  end

  add_index "reminders", ["idea_id"], :name => "index_reminders_on_idea_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                                     :default => false
    t.string   "state",                                     :default => "pending"
    t.string   "activation_code",             :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",         :limit => 40
    t.datetime "reset_password_mail_sent_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end

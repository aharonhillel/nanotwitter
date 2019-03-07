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

ActiveRecord::Schema.define(version: 2019_02_25_224024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "tweets_id"
    t.text "content"
    t.index ["tweets_id"], name: "index_comments_on_tweets_id"
  end

  create_table "follows", force: :cascade do |t|
    t.string "follower_id"
    t.string "followed_id"
  end

  create_table "hash_tag_tweets", force: :cascade do |t|
    t.string "tweet_id"
    t.string "hash_tag_id"
  end

  create_table "hash_tags", force: :cascade do |t|
    t.text "description"
  end

  create_table "likes", id: false, force: :cascade do |t|
    t.bigint "tweet_id", null: false
    t.bigint "user_id", null: false
    t.index ["tweet_id"], name: "index_likes_on_tweet_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "mentions", id: false, force: :cascade do |t|
    t.bigint "tweet_id", null: false
    t.bigint "user_id", null: false
    t.index ["tweet_id"], name: "index_mentions_on_tweet_id"
    t.index ["user_id"], name: "index_mentions_on_user_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "retweet_id"
    t.text "content"
    t.string "img_url"
    t.string "video_url"
    t.date "date"
    t.integer "total_likes"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "full_name"
    t.date "dob"
    t.string "bio"
    t.date "api_token"
    t.string "password_hash"
  end

  add_foreign_key "comments", "tweets", column: "tweets_id"
end

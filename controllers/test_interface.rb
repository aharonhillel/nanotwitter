require 'sinatra'
require 'faker'

require_relative '../models/comment'
require_relative '../models/follow'
require_relative '../models/hash_tag'
require_relative '../models/hash_tag_tweet'
require_relative '../models/like'
require_relative '../models/mention'
require_relative '../models/user'
require_relative '../models/tweet'

enable :sessions

# Reset models
get '/test/reset/all' do
  records_affected = Comment.delete_all
  records_affected += Follow.delete_all
  records_affected += HashTag.delete_all
  records_affected += HashTagTweet.delete_all
  records_affected += Like.delete_all
  records_affected += Mention.delete_all
  records_affected += User.delete_all
  records_affected += Tweet.delete_all

  reset_auto_increment 'comments'
  reset_auto_increment 'follows'
  reset_auto_increment 'hash_tags'
  reset_auto_increment 'hash_tag_tweets'
  reset_auto_increment 'likes'
  reset_auto_increment 'mentions'
  reset_auto_increment 'users'
  reset_auto_increment 'tweets'

  a = create_test_user

  session[:username] = a.username


  content_type :json
  status 200
  {
    'operation' => 'Reset all models',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset/comments' do
  records_affected = Comment.delete_all
  reset_auto_increment 'comments'

  content_type :json
  status 200
  {
    'operation' => 'Reset comment model',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset/follows' do
  records_affected = Follow.delete_all
  reset_auto_increment 'follows'

  content_type :json
  status 200
  {
    'operation' => 'Reset follow model',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset/hash_tags' do
  records_affected = HashTag.delete_all
  reset_auto_increment 'hash_tags'

  content_type :json
  status 200
  {
    'operation' => 'Reset hash_tag model',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset/hash_tag_tweets' do
  records_affected = HashTagTweet.delete_all
  reset_auto_increment 'hash_tag_tweets'

  content_type :json
  status 200
  {
    'operation' => 'Reset hash_tag_tweet model',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset/likes' do
  records_affected = Like.delete_all
  reset_auto_increment 'likes'

  content_type :json
  status 200
  {
    'operation' => 'Reset like model',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset/mentions' do
  records_affected = Mention.delete_all
  reset_auto_increment 'mentions'

  content_type :json
  status 200
  {
    'operation' => 'Reset mention model',
    'success' => true,
    'records_removed' => records_affected
  }.to_json
end

get '/test/reset?' do
  u = params[:users]
  records_added = u.to_i
  records_removed = User.delete_all
  reset_auto_increment 'users'

  content_type :json
  status 200
  {
    'operation' => 'Reset user model',
    'success' => true,
    'records_removed' => records_removed,
    'records_added' => records_added
  }.to_json
end

get '/test/reset/tweets' do
  records_affected = Tweet.delete_all
  reset_auto_increment 'tweets'

  content_type :json
  status 200
  {
    'operation' => 'Reset tweet model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/status' do
  status 200
  byebug
  status_hash = Hash.new
  status_hash[:number_of_users] = User.all.count
  status_hash[:number_of_followers] = Follow.all.count
  status_hash[:number_of_tweets] = Tweet.all.count
  if !session[:username].nil?
    status_hash[:test_user_id] = User.find_by_username(session[:username]).id
    status_hash[:test_user_username] = session[:username]
  else
      status_hash[:test_user] = nil
  end
  status_hash.to_json
end

get '/test/seed/all' do
  load './db/seed.rb'
end

# Fill dummy data
get '/test/users/create/:total' do
  total = params[:total].to_i
  total.times do
    u = User.new(username: Faker::Name.name, email: Faker::Internet.email)
    u.password = 'password'
    u.save
  end
  status 200
  {
    'operation' => 'Created dummy users',
    'success' => true,
    'records_affected' => total
  }.to_json
end

def reset_auto_increment(table_name)
  ActiveRecord::Base.connection.execute(
    "TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE"
  )
end

# Create testUser
def create_test_user
  u = User.new(username: 'testuser', email: 'testuser@sample.com')
  u.password = 'password'
  u.save
  u
end

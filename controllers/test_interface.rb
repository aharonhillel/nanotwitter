require 'sinatra'

require_relative '../models/comment'
require_relative '../models/follow'
require_relative '../models/hash_tag'
require_relative '../models/hash_tag_tweet'
require_relative '../models/like'
require_relative '../models/mention'
require_relative '../models/user'
require_relative '../models/tweet'

# Resetting models
get '/reset/all' do
  records_affected = Comment.delete_all
  + Follow.delete_all
  + HashTag.delete_all
  + HashTagTweet.delete_all
  + Like.delete_all
  + Mention.delete_all
  + User.delete_all
  + Tweet.delete_all

  content_type :json
  status 200
  {
    'operation' => 'Reset all models',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/comments' do
  records_affected = Comment.delete_all
  reset_auto_increment 'comments'

  content_type :json
  status 200
  {
    'operation' => 'Reset comment model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/follows' do
  records_affected = Follow.delete_all
  reset_auto_increment 'follows'

  content_type :json
  status 200
  {
    'operation' => 'Reset follow model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/hash_tags' do
  records_affected = HashTag.delete_all
  reset_auto_increment 'hash_tags'

  content_type :json
  status 200
  {
    'operation' => 'Reset hash_tag model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/hash_tag_tweets' do
  records_affected = HashTagTweet.delete_all
  reset_auto_increment 'hash_tag_tweets'

  content_type :json
  status 200
  {
    'operation' => 'Reset hash_tag_tweet model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/likes' do
  records_affected = Like.delete_all
  reset_auto_increment 'likes'

  content_type :json
  status 200
  {
    'operation' => 'Reset like model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/mentions' do
  records_affected = Mention.delete_all
  reset_auto_increment 'mentions'

  content_type :json
  status 200
  {
    'operation' => 'Reset mention model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/users' do
  records_affected = User.delete_all
  reset_auto_increment 'users'

  content_type :json
  status 200
  {
    'operation' => 'Reset user model',
    'success' => true,
    'records_affected' => records_affected
  }.to_json
end

get '/reset/tweets' do
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
  'healthy'
end

post '/users/create' do
end

def reset_auto_increment(table_name)
  ActiveRecord::Base.connection.execute(
    "ALTER TABLE #{table_name} AUTO_INCREMENT = 1"
  )
end

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
  query = "{
    uids(func: eq(Type, \"User\")) {
      u as uid
    }
    result(func: uid(u)) {
      count(uid)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 10)
  num_of_users = res.dig(:result).first.dig(:count)
  
  query = "{
    uids(func: eq(Type, \"Tweet\")) {
      u as uid
    }
    result(func: uid(u)) {
      count(uid)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 10)
  num_of_tweets = res.dig(:result).first.dig(:count)

  query = "{
    uids(func: has(Follow)) {
      u as uid
    }

    result(func: uid(u)) {
      count(uid)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 10)
  num_of_follows = res.dig(:result).first.dig(:count)

  query = "{
    testuser(func: eq(Username, \"testuser\")) {
      expand(_all_)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 10)
  if res.nil?
    create_test_user
  end
  {
    numOfUsers: num_of_users,
    numOfFollows: num_of_follows,
    numOfTweets: num_of_tweets,
    testUsername: 'testuser'
  }.to_json
end

# required paths
# Fill dummy data
get '/test/users/create/:total' do
  total = params[:total].to_i
  total.times do
    create_user(Faker::Internet.unique.email, Faker::Lorem.unique.words(1), 'password')
  end
  status 200
  {
    'operation' => 'Created dummy users',
    'success' => true,
    'records_affected' => total
  }.to_json
end

post '/test/user/:username/tweets?:count' do
  username = params[:username]
  uid = username_to_uid(username)
  count = params[:count].to_i

  if uid.nil?
    status 404
    'No such user'
  end

  count.times do
    tweet = "{set{
    _:tweet <Text> \"#{Faker::Lorem.sentence(6)}\" .
    _:tweet <Type> \"Tweet\" .
    _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
    <#{uid}> <Tweet> _:tweet .
    }}"

    $dg.mutate(query: tweet)
  end
  redirect "/users/#{username}"
end

def reset_auto_increment(table_name)
  ActiveRecord::Base.connection.execute(
    "TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE"
  )
end

get '/test/login/user/:username' do
  session[:username] = params[:username]
  'Logged in'
  redirect "/users/#{session[:username]}/timeline"
end

# Create testUser
get '/test/user/testuser' do
  create_test_user
  redirect '/users/testuser/timeline'
end

def create_test_user
  query = "{
    q(func: eq(Username, \"testuser\")) {
      uid
    }
  }"

  res = $dg.query(query: query)
  if res.nil?
    query = "{set{
      _:user <Username> \"testuser\" .
      _:user <Email> \"testuser@sample.com\" .
      _:user <Password> \"password\" .
      _:user <Type> \"User\" .
    }}"
    $dg.mutate(query: query)
  end
end

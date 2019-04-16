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

require_relative '../db/setup_dgraph'

enable :sessions

# Reset models
post '/test/reset/all' do
  drop_all
  setup_schema
  create_test_user

  content_type :json
  status 200
  {
    'operation' => 'Reset all models',
    'success' => true
  }.to_json
end

post '/test/reset/standard' do
  users = params[:users].to_i

end

get '/test/reset?' do
  
end

get '/test/reset/tweets' do

end

# create a number of tweets
get '/test/tweet' do
  user_id = session[:username]
  count = params[:count].to_i

  count.each do
    create_tweet(Faker::Lorem.unique.words(3), user_id)
  end
end

get '/test/status' do
  status 200
  query = "{
    uids(func: eq(Type, \"User\")) {
      u as uid
    }
    result(func: uid(u)) {
      count(uid)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 120)
  num_of_users = res.dig(:result).first.dig(:count)

  query = "{
    uids(func: eq(Type, \"Tweet\")) {
      u as uid
    }
    result(func: uid(u)) {
      count(uid)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 120)
  num_of_tweets = res.dig(:result).first.dig(:count)

  query = "{
    uids(func: has(Follow)) {
      u as uid
    }

    result(func: uid(u)) {
      count(uid)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 120)
  num_of_follows = res.dig(:result).first.dig(:count)

  query = "{
    testuser(func: eq(Username, \"testuser\")) {
      expand(_all_)
    }
  }"
  res = from_dgraph_or_redis(query, ex: 120)
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

post '/test/user/:username/tweets' do
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

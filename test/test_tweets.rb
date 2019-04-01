require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
 Sinatra::Application
end


# describe 'POST on /tweet/new' do
#   before do
#     @u = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
#     @u.password = "hdshdfshd"
#     @u.save
#     #Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
#     post '/login',{
#         username: @u.username,
#         email: @u.email,
#         password_hash: @u.password_hash}
#   end
#   it 'New tweet' do
#     c = Faker::Lorem.characters(100)
#     post '/tweet/new',{
#          user_id: @u.id,
#          content: c}
#     byebug
#     last_response.ok?
#     json = JSON.parse(last_response.body)
#     assert_equal c, json['content']
#     assert_equal 1, json['user_id']
#   end
# end

# describe 'Test associations of tweets' do
#   before do
#     Tweet.delete_all
#     User.delete_all
#   end
#   it 'Find tweets from user' do
#     @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
#     @user.password = "hdshdfshd"
#     @user.save
#     10.times do
#     create_tweet(@user.id)
#     end
#     get "/users/#{@user.username}/tweets"
#     last_response.ok?
#     json = JSON.parse(last_response.body)
#     assert_equal 10, json.count
#   end
# end
#
# describe 'validations on POST for /tweet/create' do
#   it 'Insure user_id is present' do
#     c = Faker::Lorem.characters(100)
#     post '/tweet/create',{
#          content: c}
#     last_response.ok?
#     json = JSON.parse(last_response.body)
#     assert_equal json.first[1], "unable to create tweet"
#   end
#   it 'Insure content is present' do
#     post '/tweet/create',{
#          user_id: 5}
#     last_response.ok?
#     json = JSON.parse(last_response.body)
#     assert_equal json.first[1], "unable to create tweet"
#   end
# end

describe 'POST on /test/tweet/new' do
  before do
    @u = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
  end

  it 'Find tweets from user' do
    Tweet.create(user_id: @u.id, content: "First tweet.")
    Tweet.create(user_id: @u.id, content: "Second tweet.")
    get '/test/tweets/Thomas'
    last_response.ok?
    json = JSON.parse(last_response.body)
    json.size.must_equal 2
  end

  it 'create new tweet' do
    post '/test/tweets/new',{
        user_id: @u.id.to_s,
        content: "I find a postion at Baylor medicine center."
    }
    get '/test/tweets/Thomas'
    last_response.ok?
    json = JSON.parse(last_response.body)
    json[0]["content"].must_equal "I find a postion at Baylor medicine center."
  end

  after do
    Tweet.delete_all
    User.delete_all
  end
end

# def create_tweet(user_id)
#   Tweet.create(:user_id => user_id, :content => Faker::Lorem.characters(100))
# end


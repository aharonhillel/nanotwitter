require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'


include Rack::Test::Methods

def app
 Sinatra::Application
end


describe 'POST on /tweet/new' do
  before do
    Tweet.delete_all
    User.delete_all
    @a = User.create(:username => Faker::Name.first_name, :email => Faker::Internet.email, :password => "test")
  end
  it 'New tweet' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

    user1 = User.create(:username => Faker::Name.first_name, :email => Faker::Internet.email, :password => "test")
    c = Faker::Lorem.characters(100)
    number_tweets_before = user1.tweets.count
    post '/tweet/create',{
         user_id: user1.id,
         text: c}, 'rack.session' => { :test_user =>user1 }
    last_response.ok?
    assert_equal (number_tweets_before+1), user1.tweets.count
    assert_equal Tweet.last.user_id, user1.id
  end
end

describe 'Test associtions of tweets' do
  before do
    Tweet.delete_all
    User.delete_all
  end
  it 'Find tweets from user' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    @user.password = "hdshdfshd"
    @user.save
    10.times do
    create_tweet(@user.id)
    end
    assert_equal 10, @user.tweets.count
  end
end

describe 'validations on POST for /tweet/new' do
  # it 'Insure user_id is present' do
  #   c = Faker::Lorem.characters(100)
  #   post '/tweet/create',{
  #        content: c}
  #   last_response.ok?
  #   byebug
  #   json = JSON.parse(last_response.body)
  #   assert_equal json.first[1], "unable to create tweet"
  # end
  before do
    Tweet.delete_all
    User.delete_all
  end
  it 'Insure content is present' do

    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

      user1 = User.create(:username => Faker::Name.first_name, :email => Faker::Internet.email, :password => "test")
    post '/tweet/create',{}, 'rack.session' => { :test_user =>user1 }
    assert_equal last_response.body, 'Failed create tweet'
  end
end

def create_tweet(user_id)
  Tweet.create(:user_id => user_id, :content => Faker::Lorem.characters(100))
end

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
  end
  it 'New tweet' do
    c = Faker::Lorem.characters(100)
    post '/tweet/new',{
         user_id: 1,
         content: c}
    last_response.ok?
    json = JSON.parse(last_response.body)
    tweet = json.last
    assert_equal c, tweet['content']
    assert_equal 1, tweet['user_id']
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
    get "/users/#{@user.username}/tweets"
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 10, json.count
  end
end


def create_tweet(user_id)
  Tweet.create(:user_id => user_id, :content => Faker::Lorem.characters(100))
end
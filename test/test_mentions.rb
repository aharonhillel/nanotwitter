require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'POST on /test/mentions/new' do
  before do
    @u1 = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
    @u2 = User.create(username: "James", email: "jchapel@gmail.com", password_hash: "12345678")
    @u3 = User.create(username: "Ryan", email: "ryan@gmail.com", password_hash: "12345678")
    @t1 = Tweet.create(user_id: @u1.id, content: "We are a team.")
    @t2 = Tweet.create(user_id: @u3.id, content: "We are pure Michgan.")
  end

  it 'allows user to mention another in a tweet' do
    post '/test/mentions/new', {
        tweet_id: @t1.id.to_s,
        user_id: @u2.id.to_s
    }
    post '/test/mentions/new', {
        tweet_id: @t2.id.to_s,
        user_id: @u2.id.to_s
    }
    get '/test/mentions/tweets/James'

    last_response.ok?
    json = JSON.parse(last_response.body)
    json.size.must_equal 2
  end

  after do
    Mention.delete_all
    Tweet.delete_all
    User.delete_all
  end
end

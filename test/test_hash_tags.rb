require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'Hashtag and tweets' do
  before do
    @u1 = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
    @u2 = User.create(username: "Jay", email: "jay@gmail.com", password_hash: "12345678")
    @u3 = User.create(username: "Time", email: "time@gmail.com", password_hash: "12345678")
    @t = Tweet.create(user_id: @u1.id, content: "We are a team.")
  end

  it 'can create hashtag' do
    post '/test/hashtags/new', {
        description: "Team"
    }
    get '/test/hashtags/hashtag/Team'
    last_response.ok?
    json = JSON.parse(last_response.body)
    json["description"].must_equal "Team"
  end

  it 'can archive tweets with hashtag' do
    h = HashTag.create(description: "Atlant")
    t1 = Tweet.create(user_id: @u1.id, content: "I love Atlanta")
    t2 = Tweet.create(user_id: @u2.id, content: "I miss Atlanta")
    t3 = Tweet.create(user_id: @u3.id, content: "I will go back to Atlanta some day")
    post '/test/hashtagTweets/new', {
        tweet_id: t1.id.to_s,
        hash_tag_id: h.id.to_s
    }
    post '/test/hashtagTweets/new', {
        tweet_id: t2.id.to_s,
        hash_tag_id: h.id.to_s
    }
    post '/test/hashtagTweets/new', {
        tweet_id: t3.id.to_s,
        hash_tag_id: h.id.to_s
    }
    get '/test/hashtags/tweets/Atlant'
    last_response.ok?
    json = JSON.parse(last_response.body)
    json.size.must_equal 3
  end

  after do
    HashTagTweet.delete_all
    HashTag.delete_all
    Tweet.delete_all
    User.delete_all
  end
end

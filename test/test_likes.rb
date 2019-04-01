require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'User like or unlike tweets' do
  before do
    @u1 = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
    @u2 = User.create(username: "Jame", email: "jchapel@gmail.com", password_hash: "12345678")
    @t = create_tweet(@u1.id)
  end

  it 'user can like a tweet' do
    url = '/test/like/' + @t.id.to_s + '/new'
    post url,{
        user_id: @u2.id.to_s,
        tweet_id: @t.id.to_s
    }
    url = '/test/like/' + @t.id.to_s
    get url
    last_response.ok?
    json = JSON.parse(last_response.body)
    json.size.must_equal 1
  end

  it 'user can undo-liking on a tweet' do
    url = '/test/like/' + @t.id.to_s + '/unlike'
    post url,{
        user_id: @u2.id.to_s,
        tweet_id: @t.id.to_s
    }
    url = '/test/like/' + @t.id.to_s
    get url
    last_response.ok?
    json = JSON.parse(last_response.body)
    json.size.must_equal 0
  end

  after do
    Like.delete_all
    Tweet.delete_all
    User.delete_all
  end
end


def create_tweet(user_id)
  Tweet.create(:user_id => user_id, :content => Faker::Lorem.characters(100))
end
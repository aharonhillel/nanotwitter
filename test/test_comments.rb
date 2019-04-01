require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'POST on /test/comments/:tweet_id/new' do
  before do
    @u1 = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
    @u2 = User.create(username: "Jay", email: "jay@gmail.com", password_hash: "12345678")
    @u3 = User.create(username: "Time", email: "time@gmail.com", password_hash: "12345678")
    @t = Tweet.create(user_id: @u1.id, content: "We are a team.")
  end

  it 'allow users to comment on tweet' do
    url = '/test/comments/' + @t.id.to_s + '/new'
    post url, {
        tweet_id: @t.id,
        commenter_name: "Jay",
        content: "Don't panic."
    }
    post url, {
        tweet_id: @t.id,
        commenter_name: "Tim",
        reply_to_name: "Jay",
        content: "He's right."
    }
    url = '/test/comments/' + @t.id.to_s
    get url
    last_response.ok?
    json = JSON.parse(last_response.body)
    json.size.must_equal 2
  end

  after do
    Comment.delete_all
    Tweet.delete_all
    User.delete_all
  end
end

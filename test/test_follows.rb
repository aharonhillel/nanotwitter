ENV['APP_ENV'] = 'test'

require 'rack/test'
require 'test/unit'
require_relative '../app'

class FollowsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_user1_follows_user2
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.get '/test/reset/all'

    user1 = create_dummy_user(1)
    user2 = create_dummy_user(2)

    browser.post '/login',
                 email: user1.email,
                 password: 'password'

    browser.post '/follows/user2'
    assert browser.last_response.body.include? '<h4>Follower: user1 </h4>

<h4>Followed:user2 </h4>'
  end

  def test_user1_follows_user2_follows_user3
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.get '/test/reset/all'

    user1 = create_dummy_user(1)
    user2 = create_dummy_user(2)
    user3 = create_dummy_user(3)
    # user1 follows user2
    browser.post 'login',
                 email: user1.email,
                 password: 'password'

    browser.post '/follows/user2'
    assert browser.last_response.body.include? '<h4>Follower: user1 </h4>

<h4>Followed:user2 </h4>'
    # user2 follows user3
    browser.post 'login',
                 email: user2.email,
                 password: 'password'

    browser.post '/follows/user3'
    assert browser.last_response.body.include? '<h4>Follower: user2 </h4>

<h4>Followed:user3 </h4>'
    # user3 follows user1
    browser.post 'login',
                 email: user3.email,
                 password: 'password'

    browser.post '/follows/user1'
    assert browser.last_response.body.include? '<h4>Follower: user3 </h4>

<h4>Followed:user1 </h4>'
  end

  def create_dummy_user(id)
    user = User.new(username: "user#{id}", email: "user#{id}@gmail.com")
    user.password = 'password'
    user.save
    user
  end
end
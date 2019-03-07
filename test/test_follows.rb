require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'


include Rack::Test::Methods

def app
 Sinatra::Application
end


describe 'POST on /follows/:followed' do
  before do
    Follow.delete_all
    User.delete_all
  end
  it 'Follow a user' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

    user1 = create_dummy_user(1)
    user2 = create_dummy_user(2)
    post '/follows/user2',{}, 'rack.session' => { :user =>user1 }
    assert_equal user1.following.count, 1
    assert_equal user2.following.count, 0
    assert_equal user1.followers.count, 0
    assert_equal user2.followers.count, 1
    assert_equal user1.following.first.id, user2.id
    assert_equal user2.followers.first.id, user1.id
  end
  it 'Cant follow yourself' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

    user1 = create_dummy_user(1)
    user2 = create_dummy_user(2)
    post '/follows/user1',{}, 'rack.session' => { :user =>user1 }
    last_response.ok?
    assert_equal "Cannot follow yourself", last_response.body
    assert_equal user1.following.count, 0
    assert_equal user2.following.count, 0
    assert_equal user1.followers.count, 0
    assert_equal user2.followers.count, 0
  end
end



def create_dummy_user(id)
  user = User.new(username: "user#{id}", email: "user#{id}@gmail.com")
  user.password = 'password'
  user.save
  user
end

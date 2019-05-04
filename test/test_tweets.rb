require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
 Sinatra::Application
end

describe 'POST on /tweet/create' do
  before do
    query = "{set{
        _:user <Username> \"testT1\" .
        _:user <Email> \"testT1@gmail.com\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query)

  end
  it 'Post new tweet' do
    header = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    username = "testT1"
    c = Faker::Lorem.characters(100)
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    post '/tweet/create',{
         text: c,
         header: header}, 'rack.session' => { :username => username}, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal c, json['text']
    assert_equal username, json['user']
    assert_equal true, json['success']
  end
end

describe 'Test associations of tweets' do
  it 'Find tweets from user' do
    username = create_user()
    10.times do
    create_tweet(username)
    end
    get "/users/#{username}/tweets"
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 10, json.count
  end
end

describe 'validations on POST for /tweet/create' do
  it 'Ensure user_id is present' do
    c = Faker::Lorem.characters(100)
    post '/tweet/create',{
         content: c}
    last_response.ok?
    assert_equal last_response.body, "Failed to create tweet, most likely the reason is that you are not signed in."
  end
  it 'Insure content is present' do
    username = create_user()
    post '/tweet/create',{}
    last_response.ok?
    assert_equal last_response.body, "Your tweet is blank. Add some content!"
  end
end

def create_tweet(username)
  header = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  c = Faker::Lorem.characters(100)
  post '/tweet/create',{
       text: c,
       header: header}, 'rack.session' => { :username =>username }, format: 'json'
end

def create_user()
  username = Faker::Name.first_name
  email = Faker::Internet.email
  password = '12345678'
  post '/signup',{
        username: username,
        email: email,
        password: password},  format: 'json'
  return username

end

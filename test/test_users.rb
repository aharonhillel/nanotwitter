require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'POST on /signup' do
  # before do
  #   Tweet.delete_all
  #   User.delete_all
  # end
  it 'create new user' do
    username = Faker::Name.first_name
    email = Faker::Internet.email
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, ''

    query = "{
      login(func: eq(Email, \"#{email}\")) {
        Username
        Email
        Success: checkpwd(Password, \"#{password}\")
      }
    }"
    res = $dg.query(query: query)
    assert_equal res[:login].first.dig(:Username), username
    assert_equal res[:login].first.dig(:Email), email
    assert_equal res[:login].first.dig(:Success), true
  end

  it 'User needs username' do
    email = Faker::Internet.email
    password = '12345678'
    post '/signup', {
      email: email,
      password: password
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  it 'User needs an email' do
    username = Faker::Name.first_name
    email = Faker::Internet.email
    password = '12345678'
    @user = User.new(username: Faker::Name.first_name, email: Faker::Internet.email)
    post '/signup', {
      username: username,
      password: '12345678'
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  it 'Cant have duplicate users' do
    username = Faker::Name.first_name
    email = Faker::Internet.email
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  # it 'POST /test/login' do
  #
  #   u = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
  #   post '/test/login',{
  #       email: u.email,
  #       password: "12345678"}
  #   get '/test/users/Thomas'
  #   last_response.ok?
  #   json = JSON.parse(last_response.body)
  #   json["email"].must_equal "tclouga@gmail.com"
  #   end
  # after do
  #   # User.delete_all
  # end
end

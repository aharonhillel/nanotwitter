require 'minitest/autorun'
require 'rack/test'
require 'faker'
require 'byebug'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'POST on /signup' do
  it 'create new user' do
    username = Faker::Name.first_name + Faker::Lorem.characters(10)
    email = Faker::Internet.email
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password,
      is_test: true
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Created User'

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
      password: password,
      is_test: true,
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  it 'User needs an email' do
    username = Faker::Name.first_name + Faker::Lorem.characters(10)
    password = '12345678'
    post '/signup', {
      username: username,
      password: password,
      is_test: true
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  it 'Cant have duplicate users' do
    username = Faker::Name.first_name + Faker::Lorem.characters(10)
    email = Faker::Internet.email
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  it 'POST /login' do
    username = Faker::Name.first_name + Faker::Lorem.characters(10)
    email = Faker::Internet.email + Faker::Name.first_name
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password,
      is_test: true,
    }, format: 'json'
    assert_equal last_response.body, "Created User"
    post '/login', {
      email: email,
      password: password,
      is_test: true,
    }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json['username'], username
    assert_equal json['success'], true
  end
end

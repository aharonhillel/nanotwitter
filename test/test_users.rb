require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'POST on /signup' do
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
    password = '12345678'
    post '/signup', {
      username: username,
      password: password
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
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, 'Failed to create user'
  end

  it 'POST /login' do
    username = Faker::Name.first_name
    email = Faker::Internet.email
    password = '12345678'
    post '/signup', {
      username: username,
      email: email,
      password: password
    }, format: 'json'
    h = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    post '/login', {
      email: email,
      password: password,
      headers: h
    }, 'headers' => h
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json['username'], username
    assert_equal json['success'], true
  end
end

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
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
         username: @user.username,
         email: @user.email,
         password: "12345678"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "*/*"
  end

  it 'User needs username' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
         email: @user.email,
         password: "12345678"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "Failed"
  end

  it 'User needs an email' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
        username: @user.username,
         password: "12345678"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "Failed"
  end

  it 'Cant have duplicate users' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
        username: @user.username,
         email: @user.email,
         password: "12345678"},:format => "json"
     post '/signup',{
         username: @user.username,
          email: @user.email,
          password: "12345678"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "Failed"
  end

  it 'POST /test/login' do
    u = User.create(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
    post '/test/login',{
        email: u.email,
        password: "12345678"}
    get '/test/users/Thomas'
    last_response.ok?
    json = JSON.parse(last_response.body)
    json["email"].must_equal "tclouga@gmail.com"
    end
  after do
    User.delete_all
  end
end


def create_tweet(user_id)
  Tweet.create(:user_id => user_id, :content => Faker::Lorem.characters(100))
end

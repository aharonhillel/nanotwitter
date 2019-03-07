require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'


include Rack::Test::Methods

def app
 Sinatra::Application
end


describe 'POST on /signup' do
  before do
    User.delete_all
  end
  it 'create new user' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
         username: @user.username,
         email: @user.email,
         password: "test"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "*/*"
  end

  it 'User needs username' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
         email: @user.email,
         password: "test"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "Failed"
  end

  it 'User needs an email' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
        username: @user.username,
         password: "test"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "Failed"
  end

  it 'Cant have duplicate users' do
    @user = User.new(:username => Faker::Name.first_name, :email => Faker::Internet.email)
    post '/signup',{
        username: @user.username,
         email: @user.email,
         password: "test"},:format => "json"
     post '/signup',{
         username: @user.username,
          email: @user.email,
          password: "test"},:format => "json"
    last_response.ok?
    assert_equal last_response.body, "Failed"
  end
end




def create_tweet(user_id)
  Tweet.create(:user_id => user_id, :content => Faker::Lorem.characters(100))
end

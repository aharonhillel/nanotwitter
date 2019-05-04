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
    post '/' #for some reason global variables are only available after one request
    @user = Faker::Name.first_name
    email = Faker::Internet.email
    query1 = "{set{
        _:user <Username> \"#{@user}\" .
        _:user <Email> \"#{email}\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query1)

    query2 = "{
    user(func: eq(Username, \"#{@user}\")){
      uid
      }
    }"
    @uID = $dg.query(query: query2).dig(:user).first.dig(:uid)

    tweet = "{set{
    _:tweet <Text> \"A posted a tweet!\" .
    _:tweet <Type> \"Tweet\" .
    _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
    <#{@uID}> <Tweet> _:tweet .}}"
    $dg.mutate(query: tweet)

  end

  it 'user can like a tweet' do
    query3 = "{
    tweet(func: uid(#{@uID})){
      tweets: Tweet{uid}
      }
    }"
    tID = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)

    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    post '/like/' + tID + '/new',{
        context_id: tID
    }, 'rack.session' => { :username => @user }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json, tID
  end

  it 'user cannot like a tweet or comment more than once' do
    query3 = "{
    tweet(func: uid(#{@uID})){
      tweets: Tweet{uid}
      }
    }"
    tID = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)

    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    post '/like/' + tID + '/new',{
        context_id: tID
    }, 'rack.session' => { :username => @user }, format: 'json'

    post '/like/' + tID + '/new',{
        context_id: tID
    }, 'rack.session' => { :username => @user }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json, "Already liked"
  end

end

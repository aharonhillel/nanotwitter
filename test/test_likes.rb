require 'minitest/autorun'
require 'rack/test'
require 'faker'
require 'byebug'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'User like or unlike tweets' do
  before do
    post '/' #for some reason global variables are only available after one request
    query1 = "{set{
        _:user <Username> \"testerA\" .
        _:user <Email> \"testerA@gmail.com\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query1)

    query2 = "{
    user(func: eq(Username, \"testerA\")){
      uid
      }
    }"
    user = $dg.query(query: query2).dig(:user).first.dig(:uid)

    tweet = "{set{
    _:tweet <Text> \"A posted a tweet!\" .
    _:tweet <Type> \"Tweet\" .
    _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
    <#{user}> <Tweet> _:tweet ."
    $dg.mutate(query: tweet)

  end

  it 'user can like a tweet' do
    query3 = "{
    tweet(func: eq(Username, \"testerA\")){
      tweets: Tweet{uid}
      }
    }"
    byebug
    tweet = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)

    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    byebug
    post '/like/' + tweet + '/new', 'rack.session' => { :username =>"testerA" }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, "testerA tweet/comment #{tweet}"
  end

  # it 'user cannot like a tweet or comment more than once' do
  #   query3 = "{
  #   tweet(func: eq(Username, \"testerA\")){
  #     tweets: Tweet{uid}
  #     }
  #   }"
  #   tweet = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)
  #
  #   browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  #   post '/like/' + tweet + '/new', 'rack.session' => { :username =>"testerA" }, format: 'json'
  #   last_response.ok?
  #   assert_equal last_response.body, "Already liked"
  # end

end

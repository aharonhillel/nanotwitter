require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'POST on /mentions/:tweet_id/new' do
  before do
    post '/'
    query1 = "{set{
        _:user <Username> \"testerB\" .
        _:user <Email> \"testerB@gmail.com\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query1)

    query2 = "{set{
        _:user <Username> \"testerC\" .
        _:user <Email> \"testerC@gmail.com\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query2)

    tweet = "{set{
    _:tweet <Text> \"A tweet to mention someone\" .
    _:tweet <Type> \"Tweet\" .
    _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
    <#{username_to_uid("testerC")}> <Tweet> _:tweet .
    }}"
    $dg.mutate(query: tweet)
  end

  it 'can mention a user in a tweet/comment' do
    byebug
    query3 = "{
    tweet(func: eq(Username, \"testerC\")){
      tweets: Tweet{uid}
      }
    }"
    tweet = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)

    post '/mentions/' + tweet + '/new',{
        username: "testerB",
        context_id: tweet
    }, format: 'json'

    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json['u'], "testerB"
  end

  it 'list all tweets which a user is mentioned in' do
    byebug
    get '/mentions/tweets/testerB',{
        username: "testerB"
    }
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 1, json.count
  end
end

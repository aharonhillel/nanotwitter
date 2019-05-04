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
    @um = Faker::Name.first_name
    email = Faker::Internet.email
    query1 = "{set{
        _:user <Username> \"#{@um}\" .
        _:user <Email> \"#{email}\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query1)

    query2 = "{
    user(func: eq(Username, \"#{@um}\")){
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

  it 'can mention a user in a tweet/comment' do
    u = Faker::Name.first_name
    email = Faker::Internet.email
    query4 = "{set{
        _:user <Username> \"#{u}\" .
        _:user <Email> \"#{email}\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query4)

    query3 = "{
    tweet(func: uid(#{@uID})){
      tweets: Tweet{uid}
      }
    }"
    tID = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)

    post '/mentions/' + tID + '/new',{
        username: u,
        context_id: tID
    }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json, u
  end

  # it 'list all tweets which a user is mentioned in' do
  #   u = Faker::Name.first_name
  #   email = Faker::Internet.email
  #   query4 = "{set{
  #       _:user <Username> \"#{u}\" .
  #       _:user <Email> \"#{email}\" .
  #       _:user <Password> \"12345678\" .
  #       _:user <Type> \"User\" .
  #     }}"
  #   $dg.mutate(query: query4)
  #
  #   query3 = "{
  #   tweet(func: uid(#{@uID})){
  #     tweets: Tweet{uid}
  #     }
  #   }"
  #   tID = $dg.query(query: query3).dig(:tweet).first.dig(:tweets).first.dig(:uid)
  #
  #   post '/mentions/' + tID + '/new',{
  #       username: u,
  #       context_id: tID
  #   }, format: 'json'
  #
  #   get '/mentions/tweets/' + u,{
  #       username: u
  #   }
  #   last_response.ok?
  #   json = JSON.parse(last_response.body)
  #   assert_equal 1, json.count
  # end
end

require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
 Sinatra::Application
end


describe 'POST on /tweet/new' do
  before do
    post '/'
    @un = Faker::Name.first_name
    email = Faker::Internet.email
    query = "{set{
        _:user <Username> \"#{@un}\" .
        _:user <Email> \"#{email}\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query)
  end
  it 'New tweet' do
    t = Faker::Lorem.characters(100)
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    post '/tweet/create',
         {
             text: t,
             is_test: true
         }, 'rack.session' => { :username => @un }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal t, json
  end

  it 'Ensure user_id is present' do
    tt = Faker::Lorem.characters(100)
    post '/tweet/create',{
        text: tt,
        is_test: true
    }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json, "Failed to create tweet, most likely the reason is that you are not signed in."
  end

  it 'Insure content is present' do
    post '/tweet/create',{
        text: nil,
        is_test: true
    }, 'rack.session' => { :username => @un }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json, "Your tweet is blank. Add some content!"
  end
end

# describe 'Test associations of tweets' do
#   before do
#     post '/'
#     @unn = Faker::Name.first_name
#     email = Faker::Internet.email
#     query = "{set{
#         _:user <Username> \"#{@unn}\" .
#         _:user <Email> \"#{email}\" .
#         _:user <Password> \"12345678\" .
#         _:user <Type> \"User\" .
#       }}"
#     $dg.mutate(query: query)
#   end
#
#   it 'Find tweets from user' do
#     10.times do
#       t = Faker::Lorem.characters(100)
#       browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
#       post '/tweet/create',
#            {
#                text: t,
#                is_test: true
#            }, 'rack.session' => { :username => @unn }, format: 'json'
#     end
#     get "/users/#{@unn}/tweets"
#     last_response.ok?
#     json = JSON.parse(last_response.body)
#     assert_equal 10, json.count
#   end
# end


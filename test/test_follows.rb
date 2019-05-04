require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'

include Rack::Test::Methods

def app
 Sinatra::Application
end


describe 'POST on /follows/follow/:followed' do
  before do
    post '/'
    query1 = "{set{
        _:user <Username> \"tester1\" .
        _:user <Email> \"tester1@gmail.com\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query1)

    @u2 = Faker::Name.first_name
    email2 = Faker::Internet.email
    query2 = "{set{
        _:user <Username> \"#{@u2}\" .
        _:user <Email> \"#{email2}\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query2)

    @u3 = Faker::Name.first_name
    email3 = Faker::Internet.email
    query3 = "{set{
        _:user <Username> \"#{@u3}\" .
        _:user <Email> \"#{email3}\" .
        _:user <Password> \"12345678\" .
        _:user <Type> \"User\" .
      }}"
    $dg.mutate(query: query3)
  end

  it 'Follow a user' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    post '/follows/follow/' + @u2,
         {
             followed: @u2
         },
         'rack.session' => { :username => "tester1" }, format: 'json'
    last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal json['followed'], @u2
  end

  it 'Cant follow the same person more than once' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    post '/follows/follow/'+ @u2,
         {
             followed: @u2
         },
         'rack.session' => { :username => "tester1" }, format: 'json'

    post '/follows/follow/'+ @u2,
         {
             followed: @u2
         },
         'rack.session' => { :username => "tester1" }, format: 'json'
    last_response.ok?
    assert_equal last_response.body, "Already followed".to_json
  end

  it 'can tell how many users you followed' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    query = "{
    following(func: eq(Username, \"tester1\")){
      num: count(Follow)
      }
    }"
    num = $dg.query(query: query).dig(:following).first.dig(:num)
    post '/follows/follow/' + @u3,
         {
             followed: @u3
         },
         'rack.session' => { :username => "tester1" }, format: 'json'
    last_response.ok?
    query1 = "{
    following(func: eq(Username, \"tester1\")){
      num: count(Follow)
      }
    }"
    res = $dg.query(query: query1).dig(:following).first.dig(:num)
    assert_equal res, num+1
  end

  it 'can tell how many users followed you' do
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    #header = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

    post '/follows/follow/tester1',
         {
             followed: "tester1"
         },
         'rack.session' => { :username => "tester1" }, format: 'json'
    last_response.ok?
    query = "{
    following(func: eq(Username, \"tester1\")){
      num: count(~Follow)
      }
    }"
    res = $dg.query(query: query).dig(:following).first.dig(:num)
    assert_equal res, 1
  end
end

# describe 'GET on /follows/followers/:username' do
#   before do
#     query1 = "{set{
#         _:user <Username> \"tester4\" .
#         _:user <Email> \"tester4@gmail.com\" .
#         _:user <Password> \"12345678\" .
#         _:user <Type> \"User\" .
#       }}"
#     $dg.mutate(query: query1)
#
#     query2 = "{set{
#         _:user <Username> \"tester5\" .
#         _:user <Email> \"tester5@gmail.com\" .
#         _:user <Password> \"12345678\" .
#         _:user <Type> \"User\" .
#       }}"
#     $dg.mutate(query: query2)
#
#     query3 = "{set{
#         _:user <Username> \"tester6\" .
#         _:user <Email> \"tester6@gmail.com\" .
#         _:user <Password> \"12345678\" .
#         _:user <Type> \"User\" .
#       }}"
#     $dg.mutate(query: query3)
#
#     query4 = "{
#     u4(func: eq(Username, \"tester4\")){
#       uid
#       }
#     }"
#     u4 = $dg.query(query: query4).dig(:u4).first.dig(:uid)
#
#     query5 = "{
#     u5(func: eq(Username, \"tester5\")){
#       uid
#       }
#     }"
#     u5 = $dg.query(query: query5).dig(:u5).first.dig(:uid)
#
#     query6 = "{
#     u6(func: eq(Username, \"tester6\")){
#       uid
#       }
#     }"
#     u6 = $dg.query(query: query6).dig(:u6).first.dig(:uid)
#
#     follow = "{set{
#     <#{cur}> <Follow> <#{following}> .}}"
#
#     $dg.mutate(query: follow)
#
#     follow = "{set{
#     <#{cur}> <Follow> <#{following}> .}}"
#
#     $dg.mutate(query: follow)
#   end
#
#   it 'tells who followed a user' do
#
#   end
#
#   it 'tells who a user followed' do
#
#   end
# end




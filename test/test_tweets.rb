require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app.rb'
require_relative '../models/tweet'
require_relative '../controllers/tweet'


include Rack::Test::Methods

def app
 Sinatra::Application
end


describe 'POST on /tweet/new' do
  before do
    Tweet.delete_all
  end
  it 'New tweet' do
    c = Faker::Lorem.characters(100)
    post '/tweet/new',{
         user_id: 1,
         content: c}
    last_response.ok?
    json = JSON.parse(last_response.body)
    tweet = json.last
    assert_equal c, tweet['content']
    assert_equal 1, tweet['user_id']
  end
end

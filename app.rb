require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'byebug'
require 'date'
require 'redis'
require_relative 'config/config'
require_relative 'vendor/dgraph/dgraph'
require 'json'


before do
  $redis = Redis.new(host: settings.redis_host, port: settings.redis_port)
  $dg = Dgraph::Client.new(host: settings.dgraph_host, port: settings.dgraph_port)
end

get '/update-timelines/:username' do
  tweet_username = params[:username].to_s
  query = "{profile(func: eq(Username,#{tweet_username})) {
      Follow{
        Username
      }
    }
}"

res = $dg.query(query: query)
followers = res.dig(:profile).first.dig(:Follow)
if !followers.nil?
followers.each do |a|
  follower_username = a[:Username]
  thr = Thread.new{update_redis(follower_username)}
  thr.join
end
end

puts "Done Updating Follower's Feeds"
end


def update_redis (username)
  query = "{
    var(func: eq(Username, \"#{username}\")) {
      Follow {
        f as Tweet
      }
    }
    timeline(func: uid(f), orderdesc: Timestamp, first: 20){
      uid
      tweetedBy: ~Tweet { Username }
      tweet: Text
      totalLikes: count(~Like)
      totalComments: count(~Comment_on)
      Timestamp
    }
  }"
  $redis.del(query)
  res = $dg.query(query: query)
  $redis.set(query, res.to_json, ex: 120)
  puts "Thread Completed"
end

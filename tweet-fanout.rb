require 'sinatra'
require 'byebug'
require 'redis'
require_relative 'config/config'
require_relative 'vendor/dgraph/dgraph'
require 'json'

before do
  $redis = Redis.new(host: settings.redis_host, port: settings.redis_port)
  $dg = Dgraph::Client.new(host: settings.dgraph_host, port: settings.dgraph_port)
  @queue = Queue.new
  background_worker()
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
  unless followers.nil?
    followers.each do |a|
      @queue.push(a[:Username])
    end
    puts "Finished adding usernames to queue"
  end
end

def update_redis(username)
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
  puts  "Updated Redis"
end


def background_worker
Thread.new do
  while true do
    until @queue.empty?
      work_unit = @queue.pop
      puts "popped #{work_unit}"
      update_redis(work_unit)
    end
    sleep 30
    puts "Done Updating Follower's Feeds after 30 seconds"
  end
end
end

# require 'sinatra'
# require 'byebug'
require 'redis'
# require_relative 'config/config'
require_relative 'vendor/dgraph/dgraph'
require 'json'
require 'bunny'



def action_decider(body)
  parsed_json = JSON.parse(body)
  if parsed_json["action"] == "New Tweet"
    new_tweet(parsed_json)
  end
end

def new_tweet(parsed_json)
  username = parsed_json["username"].to_s
  $dg.mutate(query: parsed_json["query"])
  update_own_profile(username)
  update_timelines_of_followers(username)
end

def update_timelines_of_followers(tweet_username)
  query = "{profile(func: eq(Username, \"#{tweet_username}\")) {
      Follow{
        Username
      }
    }
  }"
  # TODO: cache the followers in redis
  res = $dg.query(query: query)
  followers = res.dig(:profile).first.dig(:Follow)
  update_redis_of_followers(tweet_username) #update your own timeline
  unless followers.nil?
    followers.each do |a|
      follower_username = a[:Username]
      update_redis_of_followers(follower_username)
    end
  end
  puts "Done Updating Follower's Feeds"
end

def update_redis_of_followers(username)
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
  $redis.del("#{username}:timeline")
  res = $dg.query(query: query)
  $redis.set("#{username}:timeline", res.to_json)
end


def update_own_profile(username)
  query = "{
      profile(func: eq(Username, \"#{username}\")){
        uid
        tweets: Tweet(orderdesc: Timestamp, first: 20) {
          uid
          tweetedBy: ~Tweet { Username }
          tweet: Text
          totalLikes: count(~Like)
          totalComments: count(~Comment_on)
          Timestamp
        }
        totalFollowing: count(Follow)
        Follow {
          Username
        }
        totalFollower: count(~Follow)
      }
    }"

    $redis.del("#{username}:profile")
    res = $dg.query(query: query)
    $redis.set("#{username}:profile", res.to_json)
  end


  # $redis = Redis.new(host: settings.redis_host, port: settings.redis_port)
  # $dg = Dgraph::Client.new(host: settings.dgraph_host, port: settings.dgraph_port)


  $redis = Redis.new(host: ENV['REDIS_HOSTNAME'], port: ENV['REDIS_PORT'])
  $dg = Dgraph::Client.new(host: ENV['DGRAPH_HOST'], port: ENV['DGRAPH_PORT'])

  # connection = Bunny.new(host: '127.0.0.1', port: 5672,
  #                        user: 'guest', pass: 'guest',
  #                        automatically_recover: true)

  connection = Bunny.new(host: ENV['RABBITMQ_HOST'], port: ENV['RABBITMQ_PORT'],
                         user: ENV['RABBITMQ_USER'], pass: ENV['RABBITMQ_PASS'],
                         automatically_recover: true)



  connection.start

  ch = connection.create_channel
  queue = ch.queue("task_queue", durable: true)
  puts ' [*] Waiting for messages. To exit press CTRL+C'
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] Received '#{body}'"
    action_decider(body)
  end

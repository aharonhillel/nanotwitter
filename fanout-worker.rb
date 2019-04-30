require 'redis'
require_relative 'vendor/dgraph/dgraph'
require 'json'
require 'bunny'

def action_decider(body)
  # Hash is passed in with the action to be completed.
  # For future use cases if different queues and workers are developed
  parsed_json = JSON.parse(body)
  new_tweet(parsed_json) if parsed_json['action'] == 'New Tweet'
end

def new_tweet(parsed_json)
  # Creates new tweet with Dgraph
  # Expires and updates own users feed
  # Expires and updates all follower's feeds
  username = parsed_json['username'].to_s
  $dg.mutate(query: parsed_json['query'])
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
  res = $dg.query(query: query)
  followers = res.dig(:profile).first.dig(:Follow)
  update_redis_of_followers(tweet_username) # update your own timeline so your tweets appear
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

$redis = Redis.new(host: ENV['REDIS_HOSTNAME'], port: ENV['REDIS_PORT'])
$dg = Dgraph::Client.new(host: ENV['DGRAPH_HOST'], port: ENV['DGRAPH_PORT'])


# Bunny/RabbitMQ Queue

connection = Bunny.new(host: ENV['RABBITMQ_HOST'], port: ENV['RABBITMQ_PORT'],
                       user: ENV['RABBITMQ_USER'], pass: ENV['RABBITMQ_PASS'],
                       automatically_recover: true)

connection.start

ch = connection.create_channel
queue = ch.queue('task_queue', durable: true)
puts ' [*] Waiting for messages. To exit press CTRL+C'
queue.subscribe(block: true) do |_delivery_info, _properties, body|
  puts " [x] Received '#{body}'"
  action_decider(body)
end

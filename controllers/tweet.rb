require 'date'

helpers do
  # create_tweet create a tweet, and any hashtags/mentions related to the tweet
  # by default, create_tweet will not directly write to db, but instead send
  # to a worker to queue for writing to dgraph
  def create_tweet(text, user)
    # Schema check before inserting to db
    if user.nil?
      return "Failed to create tweet, most likely the reason is that you are not signed in."
    elsif text.nil?
        return "Your tweet is blank. Add some content!"
    elsif user.nil?
      return "Failed to create tweet, most likely the reason is that you are not signed in."
    elsif text.length > 280
      return "Your tweet is more than 280 characters. Make it shorter!"
    end

    tweet = "{set{
      _:tweet <Text> \"#{text}\" .
      _:tweet <Type> \"Tweet\" .
      _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
      <#{username_to_uid(user)}> <Tweet> _:tweet ."

    if text.include? '#'
      hashtags = text.scan(/#(\w+)/)
      i = 0
      hashtags.each do |h|
        tweet << "
        _:hashtag#{i} <Text> \"#{h.first}\" .
        _:hashtag#{i} <Type> \"Hashtag\" .
        _:tweet <Hashtag> _:hashtag#{i} ."
        i = i + 1
      end
    end

    if text.include? '@'
      mentioned_users = text.scan(/@(\w+)/)
      mentioned_users.each do |u|
        user = username_to_uid(u.first)
        tweet << "
          _:tweet <Mention> <#{user}> ."
      end
    end
    tweet << "}}"

    sent_data = {
      query: tweet,
      username: current_user,
      action: "New Tweet",
    }

    #RabbitMQ/Bunny publisher
    puts "Creating tweets here"

    connection = Bunny.new(host: settings.rabbitmq_host, port: settings.rabbitmq_port,
                           user: settings.rabbitmq_user, pass: settings.rabbitmq_pass,
                           automatically_recover: true)
    connection.start unless connection.open?

    ch = connection.create_channel
    q  = ch.queue("task_queue", :durable => true)

    q.publish(sent_data.to_json,
      :timestamp      => Time.now.to_i,
      :routing_key    => "process"
    )
    puts " [x] Sent Data to Queue"

    connection.close
  end
end

# Create tweet through UI
post '/tweet/create' do
  create_tweet(params[:text], current_user)
  redirect "/users/#{current_user}"
end

# Show all the tweets, by default updates every 10 minutes
get '/tweets/all' do
  query = "{
    tweets(func: eq(Type, \"Tweet\"), first: 100) {
      tweetedBy: ~Tweet {
        Username
      }
      Text
      Timestamp
    }
  }"
  res = from_dgraph_or_redis('all_tweet', query, ex: 600)
  @tweets = res.dig(:tweets)
  erb :'/tweets/tweetsAll'
end

#  Create retweet, same logic with tweeting
post '/tweets/retweet/:tweet_id' do
  text = params[:text].to_s
  query = "{
  parent(func: uid(#{params[:tweet_id]})){
    last_author: ~Tweet{Username}
    p: ~Retweet{
      uid
      Text
  	  }
    }
  }"

  p_tweet = $dg.query(query: query).dig(:parent).first.dig(:p)
  if p_tweet.nil?
    parent = params[:tweet_id]
  else
    parent = p_tweet.first.dig(:uid)
  end

  text.insert(0, p_tweet.first.dig(:last_author)).insert(0, "@")
  retweet = "{set{
    _:tweet <Text> \"#{text}\" .
    _:tweet <Type> \"Tweet\" .
    _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
    <#{username_to_uid(current_user)}> <Tweet> _:tweet .
    _:tweet <Retweet> <#{parent}>"

  if text.include? '#'
    hashtags = text.scan(/#(\w+)/)
    i = 0
    hashtags.each do |h|
      tweet << "
        _:hashtag#{i} <Text> \"#{h.first}\" .
        _:hashtag#{i} <Type> \"Hashtag\" .
        _:tweet <Hashtag> _:hashtag#{i} ."
      i = i + 1
    end
  end

  if text.include? '@'
    mentioned_users = text.scan(/@(\w+)/)
    mentioned_users.each do |u|
      user = username_to_uid(u.first)
      retweet << "
        _:tweet <Mention> <#{user}> ."
    end
  end

  retweet << "}}"

  sent_data = {
    query: retweet,
    username: current_user,
    action: "New Tweet",
  }

  @queue.publish(sent_data.to_json, persistent: true)
  puts " [x] Sent Data to Queue"

  redirect "/users/#{current_user}"
end

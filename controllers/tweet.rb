require 'date'

helpers do
  def expire_user_profile(username)
    key = "{
    profile(func: eq(Username, \"#{username}\")){
      uid
      tweets: Tweet(orderdesc: Timestamp, first: 20) {
        uid
        tweetedBy: ~Tweet { Username }
        tweet: Text
        totalLikes: count(~Like)
        totalComments: count(Comment)
        comments: Comment(orderdesc: Timestamp, first: 3) {
          commentedBy: ~Comment { User { Username } }
          comment: Text
          totalLikes: count(~Like)
          totalComments: count(Comment)
        }
        Timestamp
      }
      totalFollowing: count(Follow)
      Follow {
        Username
      }
      totalFollower: count(~Follow)
    }
  }"
    $redis.del(key)
  end

  def create_tweet(text, user_id)
    text = params[:text].to_s
    if text.nil?  || text.blank? || user_id.nil?
      if user_id.nil?
        return "Failed to create tweet, most likely the reason is that you are not signed in."
      else
        return "Your tweet is blank. Add some content!"
      end
    elsif text.length > 280
      return "Your tweet is more than 280 characters. Make it shorter!"
    end

    tweet = "{set{
      _:tweet <Text> \"#{text}\" .
      _:tweet <Type> \"Tweet\" .
      _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
      <#{username_to_uid(user_id)}> <Tweet> _:tweet ."

    if text.include? '#'
      hashtags = text.scan(/#(\w+)/)
      hashtags.each do |h|
        tweet << "
      _:hashtag <Text> \"#{h.first}\" .
      _:hashtag <Type> \"Hashtag\" .
      _:tweet <Hashtag> _:hashtag ."
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

    $dg.mutate(query: tweet)
    expire_user_profile(user_id)
    # if params[:header] != nil && params[:header][:Accept] == "application/json"
    #   h = Hash.new
    #   h[:user] = current_user
    #   h[:text] = text
    #   h[:success] = true
    #   return h.to_json
    # end
  end
end

get '/tweet/new' do
   erb :'tweets/tweet_form'
end

post '/tweet/create' do
  create_tweet(params[:text], current_user)
  redirect "/users/#{current_user}"
end

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
  res = from_dgraph_or_redis(query, ex: 600)
  @tweets = res.dig(:tweets)
  erb :'/tweets/tweetsAll'
end

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
    hashtags.each do |h|
      retweet << "
    _:hashtag <Text> \"#{h.first}\" .
    _:hashtag <Type> \"Hashtag\" .
    _:tweet <Hashtag> _:hashtag ."
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

  $dg.mutate(query: retweet)
  expire_user_profile(current_user)
  if params[:header] != nil && params[:header][:Accept] == "application/json"
    h = Hash.new
    h[:user] = current_user
    h[:text] = text
    h[:success] = true
    return h.to_json
  end
  redirect "/users/#{current_user}"
end

post '/test/tweets/new' do
  tweet = Tweet.new(:user_id => params[:user_id], :content => params[:content])
  if tweet.save
    tweet.to_json
  else
    error 404, {error: "Tweet not created"}.to_json
  end
end

get '/test/tweets/:username' do
  u = User.find_by_username(params[:username])
  if u != nil
    u.tweets.to_json
  else
    error 404, {error: "User not find"}.to_json
  end
end

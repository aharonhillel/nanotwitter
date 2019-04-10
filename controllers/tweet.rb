require 'date'

get '/tweet/new' do
   erb :'tweets/tweet_form'
end

post '/tweet/create' do
  text = params[:text].to_s
  tweet = "{set{
    _:tweet <Text> \"#{text}\" .
    _:tweet <Type> \"Tweet\" .
    _:tweet <Timestamp> \"#{DateTime.now.rfc3339(5)}\" .
    <#{current_user_uid}> <Tweet> _:tweet ."

  if text.include? '#'
    hashtag = text[/#(\w+)/]
    tweet << "
    _:tweet <Hashtag> _:hashtag .
    _:hashtag <Text> \"#{hashtag}\" .
    _:hashtag <Type> \"Hashtag\" ."
  end
  tweet << "}}"

  $dg.mutate(query: tweet)
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



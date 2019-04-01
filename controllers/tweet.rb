get '/tweet/new' do
   erb :'tweets/tweet_form'
end

post '/tweet/create' do
  tweet = Tweet.new(:user_id => current_user.id, :content => params[:text])
  "Create tweet"
  if tweet.save
    $redis.set("#{current_user.username}:tweets", current_user.tweets.to_json)
    redirect "/users/#{current_user.username}"
  else
    'Failed create tweet'
  end
end

get '/tweet/get_tweets/:id' do
  id = params[:id]
  @tweet = Tweet.find(id)
  erb :'/tweets/show'
end

# get '/tweet/:username/following_tweets' do
#   @following_tweets = current_user.followingTweets
#
#   erb :'timeline/timeline.html', :layout => :'users/homepage'
# end

get '/tweets/all' do
  @tweets = Tweet.all
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



get '/tweet/new' do
   erb :'tweets/tweet_form'
end

post '/tweet/create' do
  tweet = Tweet.new(:user_id => current_user.id, :content => params[:text])
  "Create tweet"
  if tweet.save
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

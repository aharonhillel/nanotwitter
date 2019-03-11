get '/tweet/new' do
  if current_user.nil?
        "You are not signed in, please sign in to tweet"
  else
  erb :'tweets/tweet_form'
end
end

# post '/tweet/new' do
#   if !current_user_id.nil?
#     user_id = session[:user_id]
#   else
#     user_id = params["user_id"]
#   end
#   byebug
#   tweet = Tweet.new(:user_id => user_id, :retweet_id => params[:retweet_id], :content => params[:content], :img_url => params[:img_url], :video_url => params[:video_url], :date =>Time.new)
#   if tweet.save
#     tweet.to_json
#   else
#     status 404
#       {'error' => 'unable to create tweet'}.to_json
#   end
# end

post '/tweet/create' do
  if current_user.nil?
        "You are not signed in, please sign in to tweet"
  else
  tweet = Tweet.new(:user_id => current_user, :content => params[:content])
  "Create tweet"
  if tweet.save
    @tweet = tweet
    erb :'/tweets/show'
  else
    'Failed create tweet'
  end
end
end


get '/tweet/following_tweets' do

end

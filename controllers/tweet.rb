get '/tweet/new' do
  erb :'tweets/tweet_form'
end

post '/tweet/new' do
  if current_user_id.nil?
    user_id = session[:user_id]
  else
    user_id = current_user_id
  end
  tweet = Tweet.new(:user_id => user_id, :retweet_id => params[:retweet_id], :content => params[:content], :img_url => params[:img_url], :video_url => params[:video_url], :date =>Time.new)
  if tweet.save
    Tweet.all.to_json
  else
    status 404
      {'error' => 'unable to create tweet'}.to_json
  end
end

post '/tweet/create' do
  tweet = Tweet.new(:user_id => current_user_id, :content => params[:content])
  "Create tweet"
  if tweet.save
    redirect '/tweet/get_tweets/' + tweet.id.to_s
  else
    'Failed create tweet'
  end
end

get '/tweet/get_tweets/:id' do
  id = params[:id]
  @tweet = Tweet.find(id)
  erb :'/tweets/show'
end

get '/tweet/following_tweets' do

end
post '/tweet/new' do
  if params[:user_id].nil?
  user_id = session[:user_id]
else
  user_id = params[:user_id]
end
  tweet = Tweet.new(:user_id => user_id, :retweet_id => params[:retweet_id], :content => params[:content], :img_url => params[:img_url], :video_url => params[:video_url], :date =>Time.new)
  if tweet.save
    Tweet.all.to_json
  else
    status 404
      {'error' => 'unale to create tweet'}.to_json
  end
end

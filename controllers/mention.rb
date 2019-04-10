post '/mention/:tweet_id/new' do
  mention = Mention.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if mention.save
    "Mentioned"
  else
    'Failed to mention'
  end
end

post '/test/mentions/new' do
  mention = Mention.new(:user_id => params[:user_id], :tweet_id => params[:tweet_id])
  if mention.save
    mention.to_json
  else
    'Failed to mention'
  end
end

get '/test/mentions/tweets/:username' do
  u = User.find_by_username(params[:username])
  if u != nil
    u.mentioned_in_tweets.to_json
  else
    error 404, {error: "No such user"}.to_json
  end
end

post '/mention/:tweet_id/new' do
  mentioned_user = username_to_uid(params[:username])
  tweet = params[:context_id]
  query = "{
    tweet(func: uid(#{tweet})) {
      uid
    }
  }"
  tweet_exist = $dg.mutate(query: query).first.dig(:tweet)
  if tweet_exist != nil
    mention = "{set{
    <#{tweet}> <Mention> <#{mentioned_user}> .}}"
    $dg.mutate(query: mention)
  end
end

#Only for test purpose
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

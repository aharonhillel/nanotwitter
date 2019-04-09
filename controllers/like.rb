
post '/like/:context_id/new' do
  cur = username_to_uid(current_user)
  context = params[:context_id]
  query = "{
    like(func: uid(#{cur})){
      Like @filter(uid(#{context})){
        uid
      }
    }
  }"

  res = $dg.query(query: query).dig(:like).first
  if res.nil?
    like = "{set{
    <#{cur}> <Like> <#{context}> .}}"
    $dg.mutate(query: like)
    " #{current_user} liked tweet/comment #{context}"
  else
    "Already liked"
  end
end

post '/like/:context_id/unlike' do
  unlike = "{delete{
    <#{username_to_uid(current_user)}> <Like> <#{params[:context_id]}> .}}"
  $dg.mutate(query: unlike)
  " #{current_user} unliked #{params[:context_id]}"
end
  # like = Like.where(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  # Like.find(like.id).destroy
  # like.to_json

#Only for test purpose
post '/test/like/:tweet_id/new' do
  like = Like.new(:user_id => params[:user_id], :tweet_id => params[:tweet_id])
  if like.save
    # Need to update redis
    #redirect '/users/' + current_user.username + '/timeline'
    like.to_json
  else
    'Failed to like a tweet'
  end
end

post '/test/like/:tweet_id/unlike' do
  like = Like.where(:user_id => params[:user_id], :tweet_id => params[:tweet_id])
  Like.find(like.id).destroy
  like.to_json
end

get '/test/like/:tweet_id' do
  t = Tweet.find(params[:tweet_id])
  if t != nil
    t.likes.to_json
  else
    error 404, {error: "No such tweet"}.to_json
  end
end



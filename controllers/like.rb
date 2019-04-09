post '/like/:tweet_id/new' do
  cur = username_to_uid(current_user)
  tweet = params[:tweet_id]
  query = "{
    like(func: uid(#{cur})){
      Like @filter(uid(#{tweet})){
        uid
      }
    }
  }"

  res = from_dgraph_or_redis(query, ex: 120)
  if res.nil?
    like = "{set{
    <#{cur}> <Like> <#{tweet}> .}}"
    $dg.mutate(query: like)
    " #{current_user} liked tweet #{tweet}"
  end
end


post '/like/:tweet_id/unlike' do
  unlike = "{delete{
    <#{current_user_uid}> <Like> <#{params[:tweet_id]}> .}}"

  $dg.mutate(query: unlike)
  " #{current_user} unliked #{params[:tweet_id]}"
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



post '/like/:tweet_id/new' do
  like = Like.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if like.save
    # Need to update redis
    redirect '/users/' + current_user.username
    #like.to_json
  else
    'Failed to like a tweet'
  end
end

post '/like/:tweet_id/unlike' do
  like = Like.where(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  Like.find(like.id).destroy
  like.to_json
end

# Only for test purpose
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



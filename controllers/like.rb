
post '/like/:tweet_id/new' do
  like = Like.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if like.save
    # Need to update redis
    redirect '/users/' + current_user.username + '/timeline'
  else
    'Failed to like a tweet'
  end
end

post '/like/:tweet_id/unlike' do
  like = Like.where(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  Like.find(like.id).destroy
end

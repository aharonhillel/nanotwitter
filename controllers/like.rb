
post '/like/:tweet_id/new' do
  like = Like.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if like.save
    p "Liked a tweet"
    redirect '/users/' + current_user.username + '/timeline'
  else
    'Failed to like a tweet'
  end
end
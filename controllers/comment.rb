post '/comment/:tweet_id/new' do
  comment = Mention.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if comment.save
    "Mentioned"
  else
    'Failed to mention'
  end
end
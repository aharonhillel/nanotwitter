post '/mention/:tweet_id/new' do
  mention = Mention.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if mention.save
    "Mentioned"
  else
    'Failed to mention'
  end
end

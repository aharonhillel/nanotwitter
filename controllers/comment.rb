post '/comment/:tweet_id/new' do
  comment = Comment.new(:user_id => current_user.id, :tweet_id => params[:tweet_id])
  if comment.save
    comment.to_json
  else
    'Failed to mention'
  end
end

post '/test/comments/:tweet_id/new' do
  comment = Comment.new(:content => params[:content], :tweet_id => params[:tweet_id])
  if comment.save
    comment.to_json
  else
    'Failed to mention'
  end
end

get '/test/comments/:tweet_id' do
  t  = Tweet.find(params[:tweet_id])
  if t != nil
    t.comments.to_json
  else
    error 404, {error: "Tweet not found"}.to_json
  end
end


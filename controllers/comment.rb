post '/comments/:context_id/new' do
  text = params[:text].to_s
  comment = "{set{
    _:comment <Type> \"Comment\" .
    _:comment <Text> \"#{text}\" .
    <#{username_to_uid(current_user)}> <Comment> _:comment .
    _:comment <Comment_on> <#{params[:context_id]}> .
    _:comment <Timestamp> \"#{DateTime.now.rfc3339(5)}\" ."

  if text.include? '@'
    mentioned_user = text[/#@(\w+)/]
    comment << "
    _:comment <Comment> <#{mentioned_user}> ."
  end
  comment << "}}"

  $dg.mutate(query: comment)
  " #{current_user} comment on  #{params[:context_id]} : #{text}"
end

get '/comments/all/:context_id' do
  query = "{
  comments(func: uid(#{params[:context_id]})){
      ~Comment_on(orderdesc: Timestamp, first: 5){
        author: ~Comment {Username}
        Text
        Timestamp
        totalLikes: count(Like)
        totalComments: count(~Comment_on)
      }
     }
    }"
  res = from_dgraph_or_redis(query, ex: 120)
  comments = res.dig(:comments).first

  if comments.nil?
    comments = "There are no comments for this tweet. Add some!"
  end

  #Need to add front end view
  # byebug
  comments.to_json
end

# Only for test purpose
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

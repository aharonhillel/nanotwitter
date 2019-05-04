post '/comments/:context_id/new' do
  text = params[:text].to_s
  comment = "{set{
    _:comment <Type> \"Comment\" .
    _:comment <Text> \"#{text}\" .
    <#{username_to_uid(current_user)}> <Comment> _:comment .
    _:comment <Comment_on> <#{params[:context_id]}> .
    _:comment <Timestamp> \"#{DateTime.now.rfc3339(5)}\" ."

  if text.include? '@'
    mentioned_users = text.scan(/@(\w+)/)
    mentioned_users.each do |u|
      user = username_to_uid(u.first)
      comment << "
        _:comment <Mention> <#{user}> ."
    end
  end
  comment << "}}"

  $dg.mutate(query: comment)
  text.to_json
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
    "There are no comments for this tweet. Add some!".to_json
  else
    comments.to_json
  end

  #Need to add front end view

end

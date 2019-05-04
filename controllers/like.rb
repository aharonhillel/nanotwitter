
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
    context.to_json
  else
    "Already liked".to_json
  end
end

post '/like/:context_id/unlike' do
  unlike = "{delete{
    <#{username_to_uid(current_user)}> <Like> <#{params[:context_id]}> .}}"
  $dg.mutate(query: unlike)
  " #{current_user} unliked #{params[:context_id]}"
end
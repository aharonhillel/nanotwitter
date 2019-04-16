helpers do

end

post '/hashtag/new' do
  hashtag = params[:hashtag]
  tweet = params[:tweet]

  query = "{set{
    <#{tweet}> <Hashtag> _:hashtag .
    _:hashtag <Text> \"#{hashtag}\" .
    _:hashtag <Type> \"Hashtag\" .
  }}"

  $dg.mutuate(query: query)
  status_code 200
end

get '/hashtags/:hashtag' do
  hashtag = params[:hashtag]
  query = "{
    hashtag(func: eq(Text, \"#{'#' + hashtag}\")) {
      taggedIn: ~Hashtag {
        expand(_all_)
      }
    }
  }"

  res = from_dgraph_or_redis(query)

  if res != nil
    status_code 200
    res.dig(:hashtag).first.to_json
  else
    status_code 404
    'hashtag not found'
  end
end
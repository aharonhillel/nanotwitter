post '/search' do
  text = params[:text]

  query = "{
    search(func: alloftext(Text, \"#{text}\"), first: 20) {
      Type
      Text
      Timestamp
    }
  }"

  res = from_dgraph_or_redis(query, ex: 120)
  if res.nil?
    status_code 404
    {
      error: "No match for search: #{text}"
    }.to_json
  else
    status_code 200
    res.dig(:search).to_json
  end
end
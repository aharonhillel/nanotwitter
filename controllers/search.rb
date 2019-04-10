post '/search' do
  text = params[:text].to_s

  type = "Tweet"
  if text.include? '#'
    type = "Hashtag"
  end

  query = "{
    search(func: alloftext(Text, \"#{text}\"), first: 20) @filter(eq(Type, \"#{type}\")) {
      Type
      Text
    }
  }"

  if text.include? '@'
    query = "{
      search(func: eq(Username, \"#{text[1..-1]}\")) 	{
        Username
        Email
      }
    }"
  end

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
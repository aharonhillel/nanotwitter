post '/mentions/:context_id/new' do
  mentioned_user = username_to_uid(params[:username])
  tweet = params[:context_id]
  # query = "{
  #   tweet(func: uid(#{tweet})) {
  #     uid
  #   }
  # }"
  #tweet_exist = $dg.mutate(query: query).first.dig(:tweet)
  #if tweet_exist != nil
    mention = "{set{
    <#{tweet}> <Mention> <#{mentioned_user}> .}}"
    $dg.mutate(query: mention)
    params[:username].to_json
end

get '/mentions/tweets/:username' do
  user = username_to_uid(params[:username])
  query = "{
  tweets(func: uid(#{user})){
     tweets: ~Mention(orderdesc: Timestamp, first: 20){
        uid
        tweetedBy: ~Tweet { Username }
        tweet: Text
        totalLikes: count(~Like)
        totalComments: count(~Comment_on)
        Timestamp
        }
       }
      }"
  res = from_dgraph_or_redis(query, ex: 600)
  byebug
  @tweets = res.dig(:tweets).first
  @tweets.to_json
end
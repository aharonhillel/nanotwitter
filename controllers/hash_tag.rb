post '/test/hashtags/new' do
  h = HashTag.new(:description => params[:description])
  if h.save
    h.to_json
  else
    "Failed"
  end
end

get '/test/hashtags/hashtag/:hashtag' do
  h = HashTag.find_by_description(params[:hashtag])
  if h != nil
    h.to_json
  else
    error 404, {error: "Hashtag not find"}.to_json
  end
end

post '/test/hashtagTweets/new' do
  h = HashTagTweet.new(:tweet_id => params[:tweet_id], :hash_tag_id => params[:hash_tag_id])
  if h.save
    h.to_json
  else
    "Failed"
  end
end

get '/test/hashtags/tweets/:hashtag' do
  h = HashTag.find_by_description(params[:hashtag])
  if h != nil
    h.tweets.to_json
  else
    error 404, {error: "Hashtag not find"}.to_json
  end
end


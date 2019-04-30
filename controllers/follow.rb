
post '/follows/follow/:followed' do
  cur = username_to_uid(current_user)
  #byebug
  following = username_to_uid(params[:followed])
  #byebug
  query = "{
    following(func: uid(#{cur})){
      Follow @filter(uid(#{following})){
        uid
      }
    }
  }"

  res = $dg.query(query: query).dig(:following).first
  if res.nil?
    follow = "{set{
    <#{cur}> <Follow> <#{following}> .}}"

    $dg.mutate(query: follow)
    "#{current_user} followed #{params[:followed]}"
    #erb :'follows/followings'
  else
    "Already followed"
  end
end

post '/follows/unfollow/:followed' do
  unfollow = "{delete{
    <#{username_to_uid(current_user)}> <Follow> <#{username_to_uid(params[:followed])}> .}}"

  $dg.mutate(query: unfollow)
  " #{current_user} unfollowed #{params[:followed]}"
  #erb :'follows/followings'
end

get '/follows/followers/:username' do
  query = "{
    followers(func: uid(#{username_to_uid(params[:username])}){
      count(~Follow)
      followers: ~Follow{
        uid
        Username
        Email
      }
    }
  }"
  res = from_dgraph_or_redis("#{params[:username]}:followers", query)
  if res.nil?
    "#{params[:username]} has no followers"
  else
    @followers = res.dig(:followers).first.dig(:followers)
    erb :'follows/followers'
  end
end

  # Show all followers
get '/follows/followings/:username' do
  query = "{
    followings(func: uid(#{username_to_uid(params[:username])})){
      followings: Follow{
        uid
        Username
        Email
      }
    }
  }"

  res = from_dgraph_or_redis("#{params[:username]}:followers", query)
  if res.nil?
    "#{params[:username]} has no followings"
  else
    @followings = res.dig(:followings).first.dig(:followings)
    erb :'follows/followings'
  end
end

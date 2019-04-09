
post '/follows/follow/:followed' do
  cur = username_to_uid(current_user)
  following = username_to_uid(params[:username])
  query = "{
    following(func: uid(#{cur})){
      Follow @filter(uid(#{following})){
        uid
      }
    }
  }"

  res = from_dgraph_or_redis(query, ex: 120)
  if res.nil?
    follow = "{set{
    <#{cur}> <Follow> <#{following}> .}}"

    $dg.mutate(query: follow)
    " #{current_user} followed #{params[:followed]}"
    #erb :'follows/followings'
  end
end

post '/follows/unfollow/:followed' do
  unfollow = "{delete{
    <#{username_to_uid(current_user)}> <Follow> <#{username_to_uid(params[:followed])}> .}}"

  $dg.mutate(query: unfollow)
  " #{current_user} unfollowed #{params[:followed]}"
  #erb :'follows/followings'
end

  # if session["user"][:id]
  #   #for testing since current user won't exsist
  #   current_user = User.find(session["user"][:id])
  # elsif session["test_user"]
  #   current_user = User.find(session["test_user"][:id])
  # end
  #
  # @followed_user = User.find_by_username(params[:followed])
  # f = Follow.new(following: @followed_user, follower: current_user)
  #   if f.save
  #     @id = f.id
  #     erb :'follows/following'
  #   else
  #     "Follow not work"
  #   end

  # Show all followers

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
  res = from_dgraph_or_redis(query)
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

  res = from_dgraph_or_redis(query, ex: 120)
  if res.nil?
    "#{params[:username]} has no followings"
  else
    @followings = res.dig(:followings).first.dig(:followings)
    erb :'follows/followings'
  end
end

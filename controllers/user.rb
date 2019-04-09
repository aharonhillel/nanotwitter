require 'json'
require 'date'

enable :sessions unless test?

helpers do
  def current_user
    session[:username]
  end

  # def current_user_uid
  #   query = "{
  #     uid(func: eq(Username, \"#{session[:username]}\")) {
  #       uid
  #     }
  #   }"
  #
  #   res = from_dgraph_or_redis(query)
  #   uid = res.dig(:uid).first.dig(:uid)
  #   uid
  # end

  def username_to_uid(username)
    query = "{
      uid(func: eq(Username, \"#{username}\")) {
        uid
      }
    }"

    res = from_dgraph_or_redis(query)
    uid = res.dig(:uid).first.dig(:uid)
    uid
  end
end

# Signup routes
get '/signup' do
  send_file File.expand_path('signup.html', settings.public_folder)
end

post '/signup' do
  qname = "{
  q(func: eq(Username, \"#{params[:username]}\")){
   uid
  }
}"
  name = from_dgraph_or_redis(qname).dig(:q).first

  qemail = "{
  uid(func: eq(Email, \"#{params[:email]}\")){
   uid
  }
}"
  email = $dg.query(query: qemail).dig(:uid).first

  if name != nil
    "Username already in use"
  elsif email != nil
    "Email already in use"
  else
    query = "{set{
    _:user <Username> \"#{params[:username]}\" .
    _:user <Email> \"#{params[:email]}\" .
    _:user <Password> \"#{params[:password]}\" .
    _:user <Type> \"User\" .
  }}"

    $dg.mutate(query: query)
    session[:username] = params[:username]
    redirect "/users/#{params[:username]}"
  end
end

# Login/Logout routes
get '/login' do
  send_file File.expand_path('login.html', settings.public_folder)
end

post '/login' do
  query = "{
    login(func: eq(Email, \"#{params[:email]}\")) {
      Username
      Email
      Success: checkpwd(Password, \"#{params[:password]}\")
    }
  }"
  res = $dg.query(query: query)
  success = res.dig(:login).first.dig(:Success)
  username = res.dig(:login).first.dig(:Username)

  if success
    session[:username] = username
    redirect "/users/#{username}/timeline"
  else
    'Login failed'
  end
end

get '/logout' do
  session.clear
  redirect '/login'
end

post '/logout' do
  session.clear
  redirect '/login'
end

# Profile route
get '/users/:username' do
  query = "{
    profile(func: eq(Username, \"#{params[:username]}\")){
      uid
      tweets: Tweet(orderdesc: Timestamp, first: 20) {
        uid
        tweetedBy: ~Tweet { Username }
        tweet: Text
        totalLikes: count(Like)
        totalComments: count(Comment)
        comments: Comment(orderdesc: Timestamp, first: 3) {
          commentedBy: ~Comment { User { Username } }
          comment: Text
          totalLikes: count(Like)
          totalComments: count(Comment)
        }
        Timestamp
      }
      totalFollowing: count(Follow)
      Follow {
        Username
      }
      totalFollower: count(~Follow)
    }
  }"

  res = from_dgraph_or_redis(query, ex: 120)
  profile = res.dig(:profile).first

  if profile.nil?
    status_code 404
    'User not found'
  else
    status_code 200
    @user_tweets = profile[:tweets]
    @user_followings = profile[:Follow]
    @trending_tweets = trending_tweets
    @info = {
      profile_user: params[:username],
      current_user: session[:username],
      total_following: profile[:totalFollowing],
      total_follower: profile[:totalFollower]
    }
    erb :'profile/profile.html', layout: :'layout_profile'
  end
end

# Display all tweets by a user as JSON
get '/users/:username/tweets' do
  query = "{
    tweets(func: eq(Username, \"#{params[:username]}\")) {
      Tweet {
        uid
        expand(_all_)
      }
    }
  }"

  res = from_dgraph_or_redis(query, ex: 120)
  tweets = res.dig(:tweets)

  if tweets.nil?
    status_code 404
    'User not found'
  else
    status_code 200
    tweets.first.dig(:Tweet).to_json
  end
end

# Show all users
get '/users' do
  query = "{
    users(func: eq(Type, \"User\")) {
      Username
      Email
    }
  }"

  res = from_dgraph_or_redis(query)
  users = res.dig(:users)

  if users.nil?
    status_code 404
    'No users'
  else
    status_code 200
    @users = users
    erb :'users/all'
  end
end

# # Show all followers
# get '/users/:username/followers' do
#   @user = User.find_by_username(params[:username])
#   if @user.nil?
#     "#{params[:username]} has no followers"
#   else
#     erb :'follows/followers'
#   end
# end

get '/users/:username/timeline' do
  query = "{
    var(func: eq(Username, \"#{params[:username]}\")) {
      Follow {
        f as Tweet
      }
    }
    timeline(func: uid(f), orderdesc: Timestamp, first: 20){
      uid
      tweetedBy: ~Tweet { Username }
      tweet: Text
      totalLikes: count(Like)
      totalComments: count(Comment)
      comments: Comment {
        uid
        commentedBy: ~Comment { User { Username } }
        comment: Text
        totalLikes: count(Like)
        totalComments: count(Comment)
      }
      Timestamp
    }
  }"

  res = from_dgraph_or_redis(query, ex: 120)
  timeline = res.dig(:timeline)

  if timeline.nil?
    status_code 404
    'User not found'
  else
    status_code 200
    @following_tweets = timeline
    @current_user = session[:username]
    @trending_tweets = trending_tweets
    erb :'timeline/timeline.html'
  end
end

def trending_tweets
  # trending of last 7 days
  date = Date.today - 7
  query = "{
    tweet as var(func: eq(Type, \"Tweet\"))
    @filter(ge(Timestamp, \"#{date.rfc3339}\")){
      l as count(Like)
    }
    trending(func: uid(tweet), orderdesc: val(l), first: 10) {
      uid
      tweetedBy: ~Tweet { Username }
      tweet: Text
      totalLikes: count(Like)
      totalComments: count(Comment)
      Timestamp
    }
  }"

  res = from_dgraph_or_redis(query, ex: 360)
  tweets = res.dig(:trending)

  if tweets.nil?
    []
  else
    tweets
  end
end
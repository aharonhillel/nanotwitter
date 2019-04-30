require 'json'
require 'date'

enable :sessions unless test?

helpers do
  def current_user
    session[:username]
  end

  def username_to_uid(username)
    if session[:uid].nil?
      query = "{
        uid(func: eq(Username, \"#{username}\")) {
          uid
        }
      }"
      res = from_dgraph_or_redis("current_user", query)
      uid = res.dig(:uid).first.dig(:uid)
      session[:uid] = uid
    else
      session[:uid]
    end
  end

  def create_user(email, username, password)
    return false if email.nil? || username.nil? || password.nil?

    qname = "{
      uid(func: eq(Username, \"#{username}\")){
       uid
      }
    }"
    name_check = $dg.query(query: qname)

    qemail = "{
      uid(func: eq(Email, \"#{email}\")){
       uid
      }
    }"
    email_check = $dg.query(query: qemail)

    if email_check.dig(:uid).empty? && name_check.dig(:uid).empty?
      query = "{set{
        _:user <Username> \"#{username}\" .
        _:user <Email> \"#{email}\" .
        _:user <Password> \"#{password}\" .
        _:user <Type> \"User\" .
      }}"

      $dg.mutate(query: query)
      true
    else
      false
    end
  end
end

# Signup routes
get '/signup' do
  send_file File.expand_path('signup.html', settings.public_folder)
end

post '/signup' do
  if create_user(params[:email], params[:username], params[:password])
    session[:username] = params[:username]
    redirect "/users/#{params[:username]}"
  else
    'Failed to create user'
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
    if (params[:headers][:Accept] == "application/json")
      return_hash = Hash.new
      return_hash[:username] = username
      return_hash[:success] = success
      return return_hash.to_json
    else
    session[:username] = username
    redirect "/users/#{username}/timeline"
  end
  else
    'Login failed'
  end
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
        totalLikes: count(~Like)
        totalComments: count(~Comment_on)
        Timestamp
      }
      totalFollowing: count(Follow)
      Follow {
        Username
      }
      totalFollower: count(~Follow)
    }
  }"

  res = from_dgraph_or_redis("#{params[:username]}:profile", query)
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
    erb :'profile/profile.html', layout: :layout_profile
  end
end

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
      totalLikes: count(~Like)
      totalComments: count(~Comment_on)
      Timestamp
    }
  }"

  res = from_dgraph_or_redis("#{params[:username]}:timeline",query)
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
      totalLikes: count(~Like)
      totalComments: count(Comment)
      Timestamp
    }
  }"

  res = from_dgraph_or_redis("trending_tweets", query)
  tweets = res.dig(:trending)

  if tweets.nil?
    []
  else
    tweets
  end
end

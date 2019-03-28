require_relative '../models/user'

enable :sessions

helpers do
  def current_user
    User.find_by_username(session[:username])
  end

  def current_user_id
    session[:user_id]
  end

  def current_user_tweets
    u = User.find_by_username(session[:username])
    if u.nil?
      [{ content: 'No tweets' }]
    else
      u.tweets
    end
  end

  # Mock function for testing profile ui
  Mock_User = Struct.new(:username, :email, :date, :bio)
  def mock_user
    Mock_User.new('Mock User', 'user@mock.com', '1999/9/9', 'Hi, im just a mock user!')
  end

  Mock_Tweet = Struct.new(:user_id, :retweet_id, :content, :date, :total_likes)
  def mock_user_tweets
    [
      Mock_Tweet.new(99, 199, 'this is a mock tweet from the mock user', '2019/03/09', 10),
      Mock_Tweet.new(99, 201, 'this is a mock tweet 2 from the mock user', '2019/03/06', 12)
    ]
  end
end

# Signup routes
get '/signup' do
  erb :'users/signup'
end

post '/signup' do
  @user = User.new(username: params[:username], email: params[:email])
  @user.password = params[:password]
  if @user.save
    session[:username] = @user.username
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt (redirect '/users/' + session[:username])
      when 'text/json'
        halt @user.to_json
    end
    end
  else
    'Failed'
    # redirect_to "/failure"
  end
end

# Login/Logout routes
get '/login' do
  erb :'users/login'
end

post '/login' do
  user = User.find_by_email(params[:email])

  if !user.nil? && user.password == params[:password]
    session[:username] = user.username
    'Logged in'
    redirect '/users/'+ session[:username] + '/timeline'
    # Need to write give_token function
    # give_token
  else
    'Wrong'
    # redirect "/login-successful"
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

# Profile routes
get '/users/:username' do
  if current_user != nil
    @profile_user = User.find_by_username(params[:username])
    erb :'profile/profile.html'
  else
    redirect '/'
  end
end

# Display all tweets by a user
get '/users/:username/tweets' do
  u = User.find_by_username(params[:username])
  if u.nil?
    "#{params[:username]} has no tweets"
  else
    u.tweets.to_json
  end
end

# Show all users
get '/users' do
  @users = User.all
  erb :'users/all'
end

# Show all followers
get '/users/:username/followers' do
  @user = User.find_by_username(params[:username])
  if @user.nil?
    "#{params[:username]} has no followers"
  else
    erb :'follows/followers'
  end
end

get '/users/:username/timeline' do
  @following_tweets = current_user.followingTweets
  erb :'timeline/timeline.html'
end

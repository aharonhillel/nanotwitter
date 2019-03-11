require_relative '../models/user'

enable :sessions

helpers do
  def current_user
    #if session[:username].nil?
      User.find_by_username(session[:username])
    #end

  end

end

get '/signup' do
  erb :'users/signup'
end

post '/signup' do
  @user = User.new(:username => params[:username], :email => params[:email])
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
    "Failed"
    #redirect_to "/failure"
  end
end

get '/users/:username' do
  @user = User.find_by_username(params[:username])
  if @user.nil?
    "No user named #{params[:username]}"
  else
    erb :'users/homepage'
  end
end


get '/login' do
  erb :'users/login'
end

post '/login' do
  #byebug
  @user = User.find_by_email(params[:email])

  if @user != nil && @user.password == params[:password]
    session[:username] = @user.username
    "Logged in"
    erb :'users/homepage'
    #Need to write give_token function
    #give_token
  else
    "Wrong"
    # redirect "/login-successful"
  end
end

get '/logout' do

end

get '/users/:username/tweets' do
  #Display all tweets by a user
  u = User.find_by_username(params[:username])
  if u.nil?
    "#{params[:username]} has no tweets"
  else
    u.tweets.to_json
  end
end

get '/users' do
  @users = User.all
  erb :'users/all'
end

get '/users/:username/followers' do
  @user= User.find_by_username(params[:username])
  if @user.nil?
    "#{params[:username]} has no followers"
  else
    erb :'follows/followers'
  end
end


require 'byebug'
enable :sessions

get '/signup' do
  erb :'users/signup'
end

post '/signup' do
  @user = User.new(:username => params[:username], :email => params[:email])
  @user.password = params[:password]
  if @user.save
    session[:username] = @user.username
    redirect '/users/' + session[:username]
  else
    "Failed"
    #redirect_to "/failure"
  end
end

get '/users/:username' do
  #@user = User.find_by_username(params[:username])
  erb :'users/homepage', { :locals => { :name => params[:username] } }
end


get '/login' do
  erb :'users/login'
end

post '/login' do
  #byebug
  @user = User.find_by_email(params[:email])
  if @user != nil && @user.password == params[:password]
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

require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'byebug'
require 'date'
require_relative 'models/user'
require_relative 'models/tweet'
# require_relative 'models/comment'
require_relative 'models/follow'
require_relative 'models/hash_tag'
require_relative 'models/hash_tag_tweet'
require_relative 'models/like'
require_relative 'models/mention'
require_relative 'controllers/tweet'
require_relative 'controllers/user'
current_dir = Dir.pwd

# Dir["#{current_dir}/controllers/*.rb"].each { |file| require file }

enable :sessions

get '/signup' do
  erb :"users/signup"
end

post '/signup' do
  @user = User.new(username: params[:username], email: params[:email])
  @user.password = params[:password]
  if @user.save
    session[:user_id] = @user.id
    redirect '/homepage'
    # erb :"users/login-successful"
  else
    redirect_to '/failure'
  end
end

get '/homepage' do
  @user = User.find(session[:user_id])
  erb :homepage
end

get '/login' do
  erb :"users/login"
end

post '/login' do
  # byebug
  @user = User.find_by_email(params[:email])
  if !@user.nil? && @user.password == params[:password]
    'Logged in'
    redirect '/homepage'
  # Need to write give_token function
  # give_token
  else
    'Wrong'
   # redirect_to "/login-successful"
 end
end

get '/logout' do
end

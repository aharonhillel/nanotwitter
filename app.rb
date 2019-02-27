require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'byebug'
require_relative 'models/user'

get "/signup" do
  erb :"users/signup"
end

post "/signup" do
  @user = User.new(:username => params[:username], :email => params[:email])
  @user.password = params[:password]
  if @user.save
    "success"
    #erb :"users/login-successful"
  else
    redirect_to "/failure"
  end
end

get "/login-successful" do
  erb :"users/login-successful"
end


get '/login' do
   erb :"users/login"
end

post '/login' do
  #byebug
  @user = User.find_by_email(params[:email])
  if @user != nil && @user.password == params[:password]
    "Loged in"
    #Need to write give_token function
     #give_token
  else
    "Wrong"
  # redirect_to "/login-successful"
 end
end

get '/logout' do

end

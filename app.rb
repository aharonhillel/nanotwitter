require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'byebug'
require_relative 'models/user'

get "/signup" do
  erb :"users/signup"
end

  post "/signup" do
    user = User.new(:username => params[:username], :password => password(params[:password]), :email => params[:email])
    if user.save
      redirect_to "/login-sucessful"
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
  byebug
@user = User.find_by_email(params[:username])
 if @user.password == params[:password]
   give_token
 else
   redirect_to "/login-successful"
 end
end

get '/logout' do

end

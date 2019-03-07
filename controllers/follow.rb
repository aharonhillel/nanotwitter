post '/follows/:followed' do
  @follower = params[:followed]
  erb :'follows/following'
end



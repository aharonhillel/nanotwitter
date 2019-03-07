post '/follows/:followed' do
  @followed = params[:followed]
  erb :'follows/following'
end



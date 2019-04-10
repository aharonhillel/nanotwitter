post '/follows/:followed' do
  if session["user"][:id]
    #for testing since current user won't exsist
    current_user = User.find(session["user"][:id])
  elsif session["test_user"]
    current_user = User.find(session["test_user"][:id])
  end
  @followed_user = User.find_by_username(params[:followed])
  f = Follow.new(following: @followed_user, follower: current_user)
    if f.save
      @id = f.id
      erb :'follows/following'
    else
      "Follow not work"
    end
end

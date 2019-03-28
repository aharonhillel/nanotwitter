post '/follows/:followed' do
  #current_user = session[:user]
  @followed_user = User.find_by_username(params[:followed])
  f = Follow.new(following: @followed_user, follower: current_user)
  #if !f.valid?
    #"Cannot follow yourself"
  #else
    if f.save
    # when 'text/html'
    #   halt
      @id = f.id
      erb :'follows/following'
    # when 'text/json'
    #   halt current_user.followers.to_json
    # end
    else
      "Follow not work"
    end
end


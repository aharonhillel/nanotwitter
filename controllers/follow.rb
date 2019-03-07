post '/follows/:followed' do
  @followed = params[:followed]
  p current_user.username
  followed_user = User.find_by_username(@followed.to_s)
  f = Follow.new(:user_id => current_user.id, :following_id => followed_user.id)

  if f.valid?
    "Cannot follow yourself"
  else
    if f.save
      @id = f.id
      erb :'follows/following'
    else
      "Follow not work"
    end
  end
end



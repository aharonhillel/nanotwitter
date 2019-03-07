require 'sinatra'

require_relative '../models/comment'
require_relative '../models/follow'
require_relative '../models/hash_tag'
require_relative '../models/hash_tag_tweet'
require_relative '../models/like'
require_relative '../models/mention'
require_relative '../models/user'
require_relative '../models/tweet'

# Resetting models
get 'reset/*' do

end

get 'reset/comment' do

end

get 'reset/follow' do

end

get 'reset/hast_tag' do

end

get '/status' do

end

post '/users/create' do

end

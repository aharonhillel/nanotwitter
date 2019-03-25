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
require_relative 'controllers/test_interface'
current_dir = Dir.pwd


require_relative 'controllers/user'
#require_relative 'controller/tweet'
# require_relative 'models/comment'
require_relative 'controllers/follow'

require_relative 'boot'


get '/' do
  erb :index
end

# loader.io
get '/loaderio-08e9f67e3891ab1cfd8b3be422621a7c' do
  send_file('loaderio-08e9f67e3891ab1cfd8b3be422621a7c.txt')
end
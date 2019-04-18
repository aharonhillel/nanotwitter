require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'byebug'
require 'date'
require 'redis'
require_relative 'vendor/dgraph/dgraph'

# require_relative 'models/user'
# require_relative 'models/tweet'
# require_relative 'models/comment'
# require_relative 'models/follow'
# require_relative 'models/hash_tag'
# require_relative 'models/hash_tag_tweet'
# require_relative 'models/like'
# require_relative 'models/mention'
# require_relative 'models/hash_tag'
# require_relative 'models/hash_tag_tweet'

require_relative 'controllers/follow'
require_relative 'controllers/user'
require_relative 'controllers/tweet'
require_relative 'controllers/like'
require_relative 'controllers/comment'
require_relative 'controllers/mention'
require_relative 'controllers/hash_tag'
require_relative 'controllers/search'
require_relative 'controllers/test_interface'

require_relative 'config/config'
require_relative 'helpers/helpers'

require 'json'

current_dir = Dir.pwd


before do
  $redis = Redis.new(host: settings.redis_host, port: settings.redis_port)
  $dg = Dgraph::Client.new(host: settings.dgraph_host, port: settings.dgraph_port)
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

# loader.io
get '/loaderio-08e9f67e3891ab1cfd8b3be422621a7c' do
  send_file('loaderio-08e9f67e3891ab1cfd8b3be422621a7c.txt')
end
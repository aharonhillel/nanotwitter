require 'sinatra'
require 'date'
require 'redis'
require 'newrelic_rpm'
require 'byebug'
require_relative 'vendor/dgraph/dgraph'

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
require 'date'
require 'bunny'

before do
  $redis = Redis.new(host: settings.redis_host, port: settings.redis_port)
  $dg = Dgraph::Client.new(host: settings.dgraph_host, port: settings.dgraph_port, pool: 15)
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

# loader.io
get '/loaderio-aae49fb72cbe679310ff0d5b965e041f' do
  send_file('loaderio-aae49fb72cbe679310ff0d5b965e041f.txt')
end

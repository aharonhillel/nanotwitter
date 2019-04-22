require 'sinatra'
require 'byebug'
require 'date'
require 'redis'
require 'newrelic_rpm'
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
<<<<<<< HEAD
require 'date'
require 'bunny'


  # connection.close


=======
>>>>>>> 06087902e81a7c9197f80c15284447fd3ecfbaee

current_dir = Dir.pwd

before do

  connection = Bunny.new(automatically_recover: false)
  connection.start

  channel = connection.create_channel
  @queue = channel.queue('task_queue', durable: true)

  
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
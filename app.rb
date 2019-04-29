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
require 'date'
require 'bunny'

current_dir = Dir.pwd

before do
  # @connection = Bunny.new(host: settings.rabbitmq_host, port: settings.rabbitmq_port,
  #                        user: settings.rabbitmq_user, pass: settings.rabbitmq_pass,
  #                        automatically_recover: true)
#   connection.start unless connection.open?
#   #
#   # if @channel.nil?
#   #   @channel = connection.create_channel(nil, 16)
#   # end
#
#   ch = connection.create_channel
# # Declare a queue with a given name, examplequeue. In this example is a durable shared queue used.
# @q  = ch.queue("task_queue", :durable => true)
#
# @x = ch.direct("example.exchange", :durable => true)
# @q.bind(@x, :routing_key => "process")


  # rescue Timeout::Error => e
  #   puts "Timeout"
  #   puts e
  # end
  # if !@channel.queue_exists?('task_queue')
  # @queue = @channel.queue('task_queue', durable: true)
  # end

  $redis = Redis.new(host: settings.redis_host, port: settings.redis_port)
  $dg = Dgraph::Client.new(host: settings.dgraph_host, port: settings.dgraph_port)
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

# loader.io
get '/loaderio-aae49fb72cbe679310ff0d5b965e041f' do
  send_file('loaderio-aae49fb72cbe679310ff0d5b965e041f.txt')
end

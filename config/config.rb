configure :development do
  # dgraph
  set :dgraph_host, '127.0.0.1'
  set :dgraph_port, 8080

  # redis
  set :redis_host, '127.0.0.1'
  set :redis_port, 6379

  # rabbitmq
  set :rabbitmq_host, '127.0.0.1'
  set :rabbitmq_port, 5672
  set :rabbitmq_user, 'guest'
  set :rabbitmq_pass, 'guest'
end

configure :test do
  # dgraph
  set :dgraph_host, '127.0.0.1'
  set :dgraph_port, 8080

  # redis
  set :redis_host, '127.0.0.1'
  set :redis_port, 6379

  # rabbitmq
  set :rabbitmq_host, '127.0.0.1'
  set :rabbitmq_port, 5672
  set :rabbitmq_user, 'guest'
  set :rabbitmq_pass, 'guest'
end

configure :production do
  # dgraph
  set :dgraph_host, ENV['DGRAPH_HOST']
  set :dgraph_port, ENV['DGRAPH_PORT']

  # redis
  set :redis_host, ENV['REDIS_HOSTNAME']
  set :redis_port, ENV['REDIS_PORT']

  # rabbitmq
  set :rabbitmq_host, ENV['RABBITMQ_HOST']
  set :rabbitmq_port, ENV['RABBITMQ_PORT']
  set :rabbitmq_user, ENV['RABBITMQ_USER']
  set :rabbitmq_pass, ENV['RABBITMQ_PASS']
end
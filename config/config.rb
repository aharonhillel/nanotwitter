configure :development do
  # redis
  set :redis_host, '127.0.0.1'
  set :redis_port, 6379

  # acorn_cache
  set :acorncache_host, '127.0.0.1'
  set :acorncache_port, 6379
  set :acorncache_password, ENV['ACORNCACHE_REDIS_PASSWORD']
end

configure :test do
  # redis
  set :redis_host, '127.0.0.1'
  set :redis_port, 6379

  # acorn_cache
  set :acorncache_host, '127.0.0.1'
  set :acorncache_port, 6379
  set :acorncache_password, ENV['ACORNCACHE_REDIS_PASSWORD']
end

configure :production do
  # dgraph
  set :dgraph_host, ENV['DGRAPH_HOST']
  set :dgraph_port, ENV['DGRAPH_PORT']

  # redis
  set :redis_host, ENV['REDIS_HOSTNAME']
  set :redis_port, ENV['REDIS_PORT']

  # acorn_cache
  set :acorncache_host, ENV['ACORNCACHE_REDIS_HOST']
  set :acorncache_port, ENV['ACORNCACHE_REDIS_PORT']
  set :acorncache_password, ENV['ACORNCACHE_REDIS_PASSWORD']
end
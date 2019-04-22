require 'json'
require 'net/http'
require 'httpclient'

class Dgraph
  class Client
    def initialize(options = {})
      pool = options[:pool] || 5
      @host = options[:host] || '127.0.0.1'
      @port = options[:port] || 8080
      @clients = []
      @async_clients = []
      pool.times do
        @clients << Net::HTTP.new(@host, @port)
        @async_clients << HTTPClient.new
      end
    end

    def alter(options = {})
      req = Net::HTTP::Post.new('/alter')
      req['accept'] = 'application/json'
      # req.continue_timeout = options[:timeout]
      req.body = options[:schema]

      res = any_client.request(req)

      body = JSON.parse(res.body, symbolize_names: true)
      body.dig(:data, :code).equal? 'Success'
    end

    def query(options = {})
      req = Net::HTTP::Post.new('/query')
      req['accept'] = 'application/json'
      # req.continue_timeout = options[:timeout]
      req.body = options[:query]

      res = any_client.request(req)

      if options[:raw]
        JSON.parse(res.body, symbolize_names: true)
      else
        JSON.parse(res.body, symbolize_names: true).dig(:data)
      end
    end

    def mutate(options = {})
      req = Net::HTTP::Post.new('/mutate')
      req['accept'] = 'application/json'
      # commit immediately
      req['X-Dgraph-CommitNow'] = true
      req.body = options[:query]

      res = any_client.request(req)

      body = JSON.parse(res.body, symbolize_names: true)

      if options[:show_uids]
        body.dig(:data, :uids)
      else
        body.dig(:data, :code).to_s.equal? 'Success'
      end
    end

    def mutate_async(options = {})
      conn = any_async_client.post_async(
        "http://#{@host}:#{@port}/mutate",
        header: {
          'accept' => 'application/json',
          'X-Dgraph-CommitNow' => true,
        },
        body: options[:query]
      )
      conn
    end

    def drop_all
      alter(schema: '{"drop_all": true}')
    end

    def drop_attr(options = {})
      attr = options[:attr]
      alter(schema: "{\"drop_attr\": \"#{attr}\"}")
    end

    def any_client
      @clients.sample
    end

    def any_async_client
      @async_clients.sample
    end
  end
end
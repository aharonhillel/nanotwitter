require 'json'
require 'faraday'
require 'net/http'

class Dgraph
  class Client
    def initialize(options = {})
      # @conn = Faraday.new(:url => "http://#{options[:host]}:#{options[:port]}") do |faraday|
      #       #   # faraday.response :logger                  # log requests and responses to $stdout
      #       #   faraday.adapter  Faraday.default_adapter
      #       # end
      pool = options[:pool] || 5
      @clients = []
      pool.times do
        @clients << Net::HTTP.new(options[:host], options[:port])
      end
    end

    def alter(options = {})
      # res = @conn.post do |req|
      #   req.url '/alter'
      #   req.headers['Content-Type'] = 'application/json'
      #   req.body = options[:schema]
      # end
      req = Net::HTTP::Post.new('/alter')
      req['accept'] = 'application/json'
      # req.continue_timeout = options[:timeout]
      req.body = options[:schema]

      res = any_client.request(req)

      body = JSON.parse(res.body, symbolize_names: true)
      body.dig(:data, :code).equal? 'Success'
    end

    def query(options = {})
      # res = @conn.post do |req|
      #   req.url '/query'
      #   req.headers['Content-Type'] = 'application/json'
      #   req.body = options[:query]
      # end

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
      # res = @conn.post do |req|
      #   req.url '/mutate'
      #   req.headers['Content-Type'] = 'application/json'
      #   req.headers['X-Dgraph-CommitNow'] = true
      #   req.body = options[:query]
      # end

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
  end
end
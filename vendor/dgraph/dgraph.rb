require 'json'
require 'net/http'

class Dgraph
  class Client
    def initialize(options = {})
      @client = Net::HTTP.new(options[:host], options[:port])
    end

    def alter(options = {})
      req = Net::HTTP::Post.new('/alter')
      req['accept'] = 'application/json'
      # req.continue_timeout = options[:timeout]
      req.body = options[:schema]

      res = @client.request(req)
      body = JSON.parse(res.body, symbolize_names: true)
      body.dig(:data, :code).equal? 'Success'
    end

    def query(options = {})
      req = Net::HTTP::Post.new('/query')
      req['accept'] = 'application/json'
      # req.continue_timeout = options[:timeout]
      req.body = options[:query]

      res = @client.request(req)

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

      res = @client.request(req)
      body = JSON.parse(res.body, symbolize_names: true)

      if options[:show_uids]
        body.dig(:data, :uids)
      else
        body.dig(:data, :code).to_s.equal? 'Success'
      end
    end

    def drop_all
      req = Net::HTTP::Post.new('/alter')
      req['accept'] = 'application/json'
      req.body = '{"drop_all": true}'

      res = @client.request(req)
      body = JSON.parse(res.body, symbolize_names: true)
      body.dig(:data, :code).equal? 'Success'
    end

    def drop_attr(options = {})
      attr = options[:attr]
      alter(schema: "{\"drop_attr\": \"#{attr}\"}")
    end
  end
end
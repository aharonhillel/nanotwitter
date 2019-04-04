require_relative '../vendor/dgraph/dgraph'

@dg = Dgraph::Client.new(host: '127.0.0.1', port: 8080)

def setup_schema
  schema = File.read(File.join(File.dirname(__FILE__), 'dgraph.schema'))

  @dg.alter(schema: schema)
end

def drop_all
  @dg.drop_all
end
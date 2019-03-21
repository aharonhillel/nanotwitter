# boot.rb read configurations and boot
require 'yaml'

require_relative 'vendor/dgraphy/dgraph'

def set_up_dgraph
  c = YAML.load_file(File.join(File.dirname(__FILE__), '/config/dgraph.yml'))
  host = c.dig('production', 'host')
  port = c.dig('production', 'port')
  $dg = Dgraph.new(host, port)
end

before do
  set_up_dgraph
end
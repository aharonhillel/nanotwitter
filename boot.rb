# boot.rb read configurations and boot
def setup_dgraph
  $dg = Dgraph.new(host: settings.dgraph_host, port: settings.dgraph_port)
end


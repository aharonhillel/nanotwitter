# boot.rb read configurations and boot
def setup_dgraph
  host = settings.dgraph_host
  port = settings.dgraph_port
  $dg = Dgraph.new(host, port)
end


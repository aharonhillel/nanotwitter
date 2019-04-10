# This file acts as a temporary seeding tool for dgraph

require_relative 'generate_dgraph'
require_relative 'setup_dgraph'

drop_all
setup_schema
generate_seed
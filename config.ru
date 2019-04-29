require './app'

configure do
   set :server, :thin
 end

run Sinatra::Application

# Example ufo/variables/development.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@cpu = 256
@environment = helper.env_vars(%Q[
  RAILS_ENV=development
  RACK_ENV=development
])

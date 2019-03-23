# Example ufo/variables/production.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@cpu = 256
@environment = helper.env_vars(%Q[
  RAILS_ENV=production
  RACK_ENV=production
  RDS_HOSTNAME=nt-maindb.c30ypiqjubc1.us-east-1.rds.amazonaws.com
  RDS_PORT=5432
  RDS_DB_NAME=nt_prod_db
  RDS_USERNAME=ntuser
  RDS_PASSWORD=ntpassword
])

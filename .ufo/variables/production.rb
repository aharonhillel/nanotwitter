# Example ufo/variables/production.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@cpu = 512
@environment = helper.env_vars(%Q[
  RAILS_ENV=production
  RACK_ENV=production
  RDS_HOSTNAME=nt-maindb.c30ypiqjubc1.us-east-1.rds.amazonaws.com
  RDS_PORT=5432
  RDS_USERNAME=ntuser
  RDS_PASSWORD=ntpassword
  REDIS_HOSTNAME=nt-redis.rryc2c.0001.use1.cache.amazonaws.com
  REDIS_PORT=6379
  DGRAPH_HOST=ec2-54-236-60-236.compute-1.amazonaws.com
  DGRAPH_PORT=8080
  RABBITMQ_HOST=ec2-54-84-127-215.compute-1.amazonaws.com
  RABBITMQ_PORT=5672
  RABBITMQ_USER=user
  RABBITMQ_PASS=KS5xdTXy0VTc
])

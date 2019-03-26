# Nanotwitter

A baby twitter.

http://product-Elb-VQ59Q2YO4G9G-1381768724.us-east-1.elb.amazonaws.com

## Contributors

- Xiangran Zhao
- Julian Ho
- Aaron Gold

## Changes

### 0.5 (3/18/19)

- Fixed multiple UI bugs involving current_user
- Updated schema to includes timestamps
- Implemented personal timeline
- Set up Loader.io for load testing
- Added monitoring capability via AWS CloudWatch
- Set up auto-scaling on AWS for multi-AZ load balancing
- Switched to use SSD storage for Postgres instead of default Magnetic drive
- New service architecure (ELB + Fargate + RDS)
- 2 fargate instances are always on
- Deployed using `ufo ship --cluster=production`
- To drop db and run migration do `UFO_ENV=production ufo task nanotwitter-web -c bin/migrate`

## Steps to run

```
bundle install

rake db:create

rake db:migrate
```

Optional:

```rake db:seed```

Tests can be ran by running:

```ruby test/test.rb```

Seed data can be run by running

```ruby db/seed.rb```
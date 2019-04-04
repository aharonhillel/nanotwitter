# Nanotwitter

A baby twitter.

http://product-Elb-VQ59Q2YO4G9G-1381768724.us-east-1.elb.amazonaws.com

## Contributors

- Xiangran Zhao @irenezxr
- Julian Ho @xumr0x
- Aaron Gold @aharonhillel

## Changes

### 0.7 (4/3/19)

- Added index for database tables
- Achieved like functionality
- Added model tests
- Modified caching logic

### 0.6 (3/23/19)

- Fixed UI bugs, and improved overall layout design
- Unified all the common UI element in one erb (like headers, menu, etc)
- New service architecure (ELB + Fargate + RDS)
- Created more loader.io test
- Added caching with Redis

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

### 0.4 (3/13/19)

- Finalized all routes and models and insured that functionality is accurate
- Reworked follows and built routes for users, tweets, follows
- Implemented seed data using activerecord import
- Created tests for users, tweets, and follows integration
- Worked on further AWS deployment, docker

### 0.3 (3/7/19)

- Implemented all the required `test` paths
- Added more views and erb
- Created tests for users, tweets, and follows
- Implemented EB, codePipeline/codeDeploy, and AWS RDS

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

# Nanotwitter

A baby twitter.

http://product-Elb-VQ59Q2YO4G9G-1381768724.us-east-1.elb.amazonaws.com

## Contributors

- Xiangran Zhao
- Julian Ho
- Aaron Gold

## Changes

### 0.6 (3/23/19)

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

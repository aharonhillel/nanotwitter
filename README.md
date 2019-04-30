# Nanotwitter

A baby twitter.

http://nanotwitter.com

## Contributors

- Xiangran Zhao @irenezxr
- Julian Ho @xumr0x
- Aaron Gold @aharonhillel

## Changes


### 0.7 (4/7/19)

- Switched from using Postgres to Dgraph
- Implemented search, trending tweets
- Caching all dgraph queries to redis
- Enabled sticky session on aws to ensure user login is preserved
- Added New Relic for performance monitoring

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

### To run App

```
ruby app.rb
```

### To run dgraph
```
docker pull dgraph/dgraph

mkdir -p ~/dgraph

# Run dgraphzero
docker run -it -p 5080:5080 -p 6080:6080 -p 8080:8080 -p 9080:9080 -p 8000:8000 -v ~/dgraph:/dgraph --name dgraph dgraph/dgraph dgraph zero

# In another terminal, now run dgraph
docker exec -it dgraph dgraph alpha --lru_mb 2048 --zero localhost:5080
```

### To seed

```
ruby db/seed_dgraph.rb

gzip db/seed.rdf

cp db/seed.rdf.gz ~/dgraph

docker exec -it dgraph dgraph live -r seed.rdf.gz --zero localhost:5080 -c 1
```
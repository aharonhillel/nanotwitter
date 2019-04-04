# DGRAPH


### Run Dgraph server first
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

gzip -y seed.rdf

cp seed.rdf.gz ~/dgraph

docker exec -it dgraph dgraph live -r seed.rdf.gz --zero localhost:5080 -c 1
```

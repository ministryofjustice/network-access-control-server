#!/bin/bash

set -ex

docker-compose stop certgenerator
docker-compose up --build -d certgenerator
docker-compose exec -T certgenerator make
docker-compose cp certgenerator:/etc/raddb/certs/ ./test
cat ./test/certs/server.key >> ./test/certs/server.pem
cat ./test/certs/ca.key >> ./test/certs/ca.pem
cat ./test/certs/client.key >> ./test/certs/client.pem
mkdir -p ./test/certs/radsec && cp -pr ./test/certs/server.pem ./test/certs/ca.pem ./test/certs/radsec/
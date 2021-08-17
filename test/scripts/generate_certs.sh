#!/bin/bash

set -ex

DOCKER_COMPOSE = docker-compose -f docker-compose.yml

$(DOCKER_COMPOSE) stop certgenerator
$(DOCKER_COMPOSE) up --build -d certgenerator
$(DOCKER_COMPOSE) exec -T certgenerator make
$(DOCKER_COMPOSE) cp certgenerator:/etc/raddb/certs/ ./test
cat ./test/certs/server.key >> ./test/certs/server.pem
cat ./test/certs/ca.key >> ./test/certs/ca.pem
cat ./test/certs/client.key >> ./test/certs/client.pem
mkdir -p ./test/certs/radsec && cp -pr ./test/certs/server.pem ./test/certs/ca.pem ./test/certs/radsec/
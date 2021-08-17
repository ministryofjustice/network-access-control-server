#!/bin/bash

set -ex

wait_for_container_to_be_ready() {
    printf "Waiting for container to be ready"
    until docker exec ${certgenerator_id} ls -al /etc/raddb/certs/server.pem
    do
        printf "."
        sleep 1
    done
    printf "\n"
}

docker-compose stop certgenerator
docker-compose up --build -d certgenerator
certgenerator_id=$(docker ps -aqf "name=certgenerator")
docker exec ${certgenerator_id} make
wait_for_container_to_be_ready
docker cp ${certgenerator_id}:/etc/raddb/certs/ ./test
cat ./test/certs/server.key >> ./test/certs/server.pem
cat ./test/certs/ca.key >> ./test/certs/ca.pem
cat ./test/certs/client.key >> ./test/certs/client.pem
mkdir -p ./test/certs/radsec && cp -pr ./test/certs/server.pem ./test/certs/ca.pem ./test/certs/radsec/
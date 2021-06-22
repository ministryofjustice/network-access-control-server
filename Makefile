DOCKER_COMPOSE = docker-compose -f docker-compose.yml

build: 
	docker build -t radius ./ 

build-dev:
	${DOCKER_COMPOSE} build

build-nginx:
	docker build -t nginx ./nginx 

run:
	${DOCKER_COMPOSE} up -d server
	${DOCKER_COMPOSE} up -d client

stop: 
	${DOCKER_COMPOSE} stop server
	${DOCKER_COMPOSE} stop client
	# ${DOCKER_COMPOSE} stop db

shell-server: 
	${DOCKER_COMPOSE} exec server bash

shell-client: 
	${DOCKER_COMPOSE} exec client bash

start-db: 
	$(DOCKER_COMPOSE) up -d db
	./scripts/wait_for_db.sh

serve: stop build-dev start-db run

authenticate-docker:
	./scripts/authenticate_docker.sh

push-nginx:
	docker tag nginx:latest ${REGISTRY_URL}/mojo-${ENV}-nac-nginx:latest
	docker push ${REGISTRY_URL}/mojo-${ENV}-nac-nginx:latest

push:
	docker tag radius:latest ${REGISTRY_URL}/mojo-${ENV}-nac:latest
	docker push ${REGISTRY_URL}/mojo-${ENV}-nac:latest

deploy: 
	./scripts/deploy.sh

publish: build push build-nginx push-nginx

test: serve
	$(DOCKER_COMPOSE) exec client sh -c ./test/test_eap.sh

.PHONY: build run build-dev push-nginx -push serve deploy test

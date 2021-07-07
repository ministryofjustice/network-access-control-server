DOCKER_COMPOSE = docker-compose -f docker-compose.yml

authenticate-docker: check-container-registry-account-id
	./scripts/authenticate_docker.sh

check-container-registry-account-id:
	./scripts/check_container_registry_account_id.sh

build: check-container-registry-account-id
	docker build -t radius ./ --build-arg SHARED_SERVICES_ACCOUNT_ID

build-dev: 
	${DOCKER_COMPOSE} build

build-nginx:
	docker build -t nginx ./nginx --build-arg SHARED_SERVICES_ACCOUNT_ID

run: start-db
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
	$(DOCKER_COMPOSE) exec -T db sh -c 'exec mysql -uradius -pradius' < test/whitelist_test_client.sql

serve: stop build-dev start-db run

deploy: 
	./scripts/deploy.sh

publish: build build-nginx
	./scripts/publish.sh

test: stop build-dev run
	$(DOCKER_COMPOSE) exec -T client /test/test_eap.sh

.PHONY: build run build-dev publish serve deploy test check-container-registry-account-id 

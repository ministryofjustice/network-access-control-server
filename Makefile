DOCKER_COMPOSE = docker-compose -f docker-compose.yml

authenticate-docker: check-container-registry-account-id
	./scripts/authenticate_docker.sh

check-container-registry-account-id:
	./scripts/check_container_registry_account_id.sh

build: check-container-registry-account-id
	docker build -t radius ./ --build-arg SHARED_SERVICES_ACCOUNT_ID

build-dev: generate-certs
	${DOCKER_COMPOSE} build

generate-certs:
	./test/scripts/generate_certs.sh

build-nginx:
	docker build -t nginx ./nginx --build-arg SHARED_SERVICES_ACCOUNT_ID

run: start-db
	${DOCKER_COMPOSE} up -d server
	${DOCKER_COMPOSE} up -d client
	${DOCKER_COMPOSE} up -d radsecproxy

stop: 
	${DOCKER_COMPOSE} stop server
	${DOCKER_COMPOSE} stop client
	${DOCKER_COMPOSE} stop radsecproxy
	# ${DOCKER_COMPOSE} stop db

shell-server: 
	${DOCKER_COMPOSE} exec server bash

shell-client: 
	${DOCKER_COMPOSE} exec client bash

shell-radsecproxy: 
	${DOCKER_COMPOSE} exec radsecproxy bash

start-db: 
	$(DOCKER_COMPOSE) up -d db
	./scripts/wait_for_db.sh

serve: stop build-dev start-db run

deploy: 
	./scripts/deploy.sh

publish: build build-nginx
	./scripts/publish.sh

test: stop build-dev run
	$(DOCKER_COMPOSE) exec -T server /test/scripts/setup_authorised_clients.sh
	$(DOCKER_COMPOSE) exec -T server /test/scripts/setup_test_mac_address.sh
	$(DOCKER_COMPOSE) exec -T server /test/scripts/setup_test_crl.sh
	$(DOCKER_COMPOSE) exec -T server /test/scripts/ocsp_responder.sh
	$(DOCKER_COMPOSE) exec -T client /test/test_eap.sh
	$(DOCKER_COMPOSE) exec -T client /test/test_crl.sh

.PHONY: build run build-dev publish serve deploy test check-container-registry-account-id generate-certs

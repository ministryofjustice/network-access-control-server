authenticate-docker: check-container-registry-account-id
	./scripts/authenticate_docker.sh

check-container-registry-account-id:
	./scripts/check_container_registry_account_id.sh

build: check-container-registry-account-id
	docker build -t radius ./ --build-arg SHARED_SERVICES_ACCOUNT_ID

build-nginx:
	docker build -t nginx ./nginx --build-arg SHARED_SERVICES_ACCOUNT_ID

deploy: 
	./scripts/deploy.sh

publish: build build-nginx
	./scripts/publish.sh

.PHONY: build run publish deploy check-container-registry-account-id 

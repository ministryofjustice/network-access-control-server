#!make
.DEFAULT_GOAL := help

.PHONY: authenticate-docker
authenticate-docker: ## ## Authenticate docker script
	./scripts/authenticate_docker.sh

.PHONY: build
build: ## Docker build Radius server
	docker build --platform=linux/amd64 -t radius ./

.PHONY: scout
scout: ## Docker scout quickview Radius server
	docker scout quickview local://radius:latest | tee `date "+%Y_%m_%d-%H_%M_%S"`_docker_scout_quickview_radius.txt

.PHONY: scout-cves
scout-cves: ## Docker scout cves Radius server
	docker scout cves local://radius:latest | tee `date "+%Y_%m_%d-%H_%M_%S"`_docker_scout_cves_radius.txt

.PHONY: scout-rec
scout-rec: ## Docker scout cves Radius server
	docker scout recommendations local://radius:latest | tee `date "+%Y_%m_%d-%H_%M_%S"`_docker_scout_recommendations_radius.txt

.PHONY: build-nginx
build-nginx: ## Docker build nginx
	docker build --platform=linux/amd64 -t nginx ./nginx

.PHONY: scout-nginx
scout-nginx: ## Docker scout quickview nginx server
	docker scout quickview local://nginx:latest | tee `date "+%Y_%m_%d-%H_%M_%S"`_docker_scout_quickview_nginx.txt

.PHONY: scout-nginx-cves
scout-nginx-cves: ## Docker scout cves nginx server
	docker scout cves local://nginx:latest | tee `date "+%Y_%m_%d-%H_%M_%S"`_docker_scout_cves_nginx.txt

.PHONY: scout-nginx-rec
scout-nginx-rec: ## Docker scout cves nginx server
	docker scout recommendations local://nginx:latest | tee `date "+%Y_%m_%d-%H_%M_%S"`_docker_scout_recommendations_nginx.txt

.PHONY: clean-scout
clean-scout: ## Delete the scout text files
	@find . -maxdepth 1 -mindepth 1 -type f -name '*_docker_scout_*' -print -delete
	@printf "Above docker scout files deleted."

.PHONY: deploy
deploy: ## Deploy RADIUS server
	./scripts/deploy.sh

.PHONY: publish
publish: ## Push Docker images to ECR
	$(MAKE) build
	$(MAKE) build-nginx
	./scripts/publish.sh

.PHONY: publish-dictionaries
publish-dictionaries: ## Publish dictionaries
	./scripts/publish_dictionaries.sh

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

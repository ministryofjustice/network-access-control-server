#!make
.DEFAULT_GOAL := help

.PHONY: authenticate-docker
authenticate-docker: ## ## Authenticate docker script
	./scripts/authenticate_docker.sh

.PHONY: build
build: ## Docker build Radius server
	docker build --platform=linux/amd64 --provenance=false -t radius ./

.PHONY: build-nginx
build-nginx: ## Docker build nginx
	docker build --platform=linux/amd64 -t nginx ./nginx

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

# Testing pipeline changes 
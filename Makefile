authenticate-docker:
	./scripts/authenticate_docker.sh

build:
	docker build --platform=linux/amd64,linux/arm64 -t radius ./

build-nginx:
	docker build --platform=linux/amd64,linux/arm64-t nginx ./nginx

deploy:
	./scripts/deploy.sh

publish: build build-nginx
	./scripts/publish.sh

publish-dictionaries:
	./scripts/publish_dictionaries.sh

.PHONY: build run publish deploy publish_dictionaires

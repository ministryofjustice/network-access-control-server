authenticate-docker:
	./scripts/authenticate_docker.sh

build:
	docker build -t radius ./

build-nginx:
	docker build -t nginx ./nginx

deploy:
	./scripts/deploy.sh

publish: build build-nginx
	./scripts/publish.sh

publish-dictionaries:
	./scripts/publish_dictionaries.sh

insert-custom-attribute:
	./scripts/insert_custom_attribute.sh

.PHONY: build run publish deploy publish_dictionaires

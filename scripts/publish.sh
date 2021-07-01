#!/bin/bash

set -e

push_image() {
    aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
    docker tag radius:latest $1
    docker push $1:latest
}

radius_repository_url=$( jq -r '.radius.ecr.repository_url' <<< "${TERRAFORM_OUTPUTS}" )
nginx_repository_url=$( jq -r '.radius.ecr.nginx_repository_url' <<< "${TERRAFORM_OUTPUTS}" )

push_image $radius_repository_name
push_image $nginx_repository_name

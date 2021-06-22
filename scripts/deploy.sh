#!/bin/bash
set -euo pipefail

deploy() {
  cluster_name=$( jq -r '.radius.ecs.cluster_name' <<< "${TERRAFORM_OUTPUTS}" )
  service_name=$( jq -r '.radius.ecs.service_name' <<< "${TERRAFORM_OUTPUTS}" )

  echo "deploying RADIUS server"
  aws ecs update-service \
    --cluster $cluster_name \
    --service $service_name \
    --force-new-deployment
}

main() {
  deploy
}

main
#!/bin/bash
set -euo pipefail

assume_deploy_role() {
  TEMP_ROLE=`aws sts assume-role --role-arn $ROLE_ARN --role-session-name ci-dhcp-deploy-$CODEBUILD_BUILD_NUMBER`
  export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
}

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
  assume_deploy_role
  deploy
}

main
#!/bin/bash
set -euo pipefail

assume_deploy_role() {
  TEMP_ROLE=`aws sts assume-role --role-arn $ROLE_ARN --role-session-name ci-nac-deploy-$CODEBUILD_BUILD_NUMBER`
  export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
}

deploy() {
  echo "deploying RADIUS server"
  aws ecs update-service \
    --cluster $1 \
    --service $2 \
    --force-new-deployment
}

main() {
  cluster_name=$( jq -r '.radius.ecs.cluster_name' <<< "${TERRAFORM_OUTPUTS}" )
  service_name=$( jq -r '.radius.ecs.service_name' <<< "${TERRAFORM_OUTPUTS}" )
  internal_service_name=$( jq -r '.radius.ecs.internal_service_name' <<< "${TERRAFORM_OUTPUTS}" )

  assume_deploy_role
  deploy $cluster_name $service_name
  deploy $cluster_name $internal_service_name
}

main
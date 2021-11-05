#!/bin/bash

set -euo pipefail

source ./scripts/aws_helpers.sh

publish_dictionaries() {
  radius_config_bucket_name=$( jq -r '.radius.s3.radius_config_bucket_name' <<< "${TERRAFORM_OUTPUTS}" )

  local publish_dictionaries_command="aws s3 sync /usr/share/freeradius/ s3://${radius_config_bucket_name}/radius_dictionaries/"
  local docker_service_name="radius-server"
  local cluster_name service_name task_definition docker_service_name

  cluster_name=$( jq -r '.radius.ecs.cluster_name' <<< "${TERRAFORM_OUTPUTS}" )
  service_name=$( jq -r '.radius.ecs.service_name' <<< "${TERRAFORM_OUTPUTS}" )
  task_definition=$( jq -r '.radius.ecs.task_definition_name' <<< "${TERRAFORM_OUTPUTS}" )

  aws sts get-caller-identity

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${publish_dictionaries_command}"
}

main() {
  assume_deploy_role
  publish_dictionaries
}

main

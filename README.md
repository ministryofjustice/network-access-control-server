# Network Access Control Server

This is the RADIUS Server for managing Network Access Control.

## Table of Contents

- [Getting Started](#getting-started)
  - [Authenticating Docker with AWS ECR](#authenticating-docker-with-aws-ecr)
  - [Starting the App](#starting-the-app)
  - [Deployment](#deployment)
    - [Targetting the ECS Cluster and Service to Deploy](#targetting-the-ecs-cluster-and-service-to-deploy)
    - [Publishing Image from Local Machine](#publishing-image-from-local-machine)
- [Policy Engine](#policy-engine)
- [RADIUS Attribute Validation](#radius-attribute-validation)
- [Performance Testing](#performance-testing)
- [What triggers a deployment of the Radius server from the Admin Portal?](#what-triggers-a-deployment-of-the-radius-server-from-the-admin-portal)

## Getting Started

### Authenticating Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured with credentials for shared services, do the following to authenticate:

```bash
aws-vault exec SHARED_SERVICES_VAULT_PROFILE_NAME -- aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin SHARED_SERVICES_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com
```

Replace ```SHARED_SERVICES_VAULT_PROFILE_NAME``` and ```SHARED_SERVICES_ACCOUNT_ID``` in the command above with the profile name and ID of the shared services account configured in aws-vault.

### Starting the App

1. To run the application locally, refer to the [Integration-Test](https://github.com/ministryofjustice/network-access-control-integration-test) repository

### Deployment

The `deploy` command is wrapped in a Makefile. It calls `./scripts/deploy` which schedules a zero downtime phased [deployment](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html) in ECS.

It doubles the currently running tasks and briefly serves traffic from the new and existing tasks in the service.
The older tasks are eventually decommissioned, and production traffic is gradually shifted over to only the new running tasks.

On CI this command is executed from the [buildspec.yml](./buildspec.yml) file after migrations and publishing the new image to ECR has been completed.

### Targetting the ECS Cluster and Service to Deploy

The ECS infrastructure is managed by Terraform. The name of the cluster and service are [outputs](https://www.terraform.io/docs/configuration/outputs.html) from the Terraform apply. These values are published to SSM Parameter Store, when this container is deployed it pulls those values from Parameter Store and sets them as environment variables.

The deploy script references these environment variables to target the ECS RADIUS service and cluster. This is to avoid depending on the hardcoded strings.

The build pipeline assumes a role to access the target AWS account.

#### Publishing Image from Local Machine

1. Export the following configurations as an environment variable.

```bash
  export NAC_TERRAFORM_OUTPUTS='{
    "radius": {
      "ecs": {
        "cluster_name": "[TARGET_CLUSTER_NAME]",
        "service_name": "[TARGET_SERVICE_NAME]"
      }
    }
  }'
```

This mimics what happens on CI where this environment variable is already set.

When run locally, you need to target the AWS account directly with AWS Vault.

2. Schedule the deployment

```bash
  aws-vault exec [target_aws_account_profile] -- make deploy
```

## User Flow and Diagrams

### Internal Authentication
![internal_authentication](./docs/diagrams/internal_authentication.drawio.svg)
### Other Diagrams
- [EAP User Flow Diagram](/docs/eap_user_flow_diagram.md)
- [RadSec User Flow Diagram](/docs/radsec_user_flow_diagram.md)
- [Policy Engine User Flow Diagram](/docs/policy_engine_document.md)

## RADIUS Attribute Validation

- In order to understand how request/response attributes are validated from the
[Network Access Control Admin](https://github.com/ministryofjustice/network-access-control-admin)
application to the FreeRADIUS server, refer to the
[attribute validation](/docs/attribute_validation.md) documentation.

## Performance Testing
- [Performance test results and guidance](/docs/performance_testing_document.md)

## What triggers a deployment of the Radius server from the Admin Portal?

1. Certificates
    - Uploading and deleting an EAP or RADSEC certificate from the Admin Portal
1. Mac Authentication Bypass
    - Adding, deleting, or updating a Mac address to the MAB list
    - Adding, deleting, or updating a MAB response in the MAB lis
1. Sites and Clients
    - Adding a Client to a Site
1. Policies
    - Policies are read using the read-replica RDS, creating a Policy does not trigger a deployment

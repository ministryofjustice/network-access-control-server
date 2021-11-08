# Network Access Control Server

This is the RADIUS Server for managing Network Access Control.

## Table of Contents

- [Getting Started](#getting-started)
  - [Authenticating Docker with AWS ECR](#authenticating-docker-with-aws-ecr)
  - [Starting the App](#starting-the-app)
- [Policy Engine](#policy-engine)
- [RADIUS Attribute Validation](#radius-attribute-validation)
- [Performance Testing](#performance-testing)

## Getting Started

### Authenticating Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured with credentials for shared services, do the following to authenticate:

```bash
aws-vault exec SHARED_SERVICES_VAULT_PROFILE_NAME -- aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin SHARED_SERVICES_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com
```

Replace ```SHARED_SERVICES_VAULT_PROFILE_NAME``` and ```SHARED_SERVICES_ACCOUNT_ID``` in the command above with the profile name and ID of the shared services account configured in aws-vault.

### Starting the App

1. Clone the repository
1. Create a `.env` file in the root directory
   1. Add `SHARED_SERVICES_ACCOUNT_ID=` to the `.env` file, entering the relevant account ID

1. Generate certificates 

```sh
$ make generate-certs
```

1. Start the application

```sh
$ make serve
```

1. Running tests

```sh
$ make test
```

1. Connect to the server shell

```sh
$ make shell-server
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

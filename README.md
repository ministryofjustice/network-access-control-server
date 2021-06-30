# Network Access Control Server

This is the RADIUS Server for managing Network Access Control

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
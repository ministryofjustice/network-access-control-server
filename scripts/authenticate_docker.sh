set -euo pipefail

aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin ${REGISTRY_URL}
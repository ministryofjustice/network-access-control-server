
#!/bin/bash
set -euo pipefail

cd /etc/raddb/certs

openssl ca -passin pass:"whatever" -config ca.cnf -revoke client.pem -keyfile ca.key -cert ca.pem
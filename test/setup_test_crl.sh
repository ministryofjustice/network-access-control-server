#!/bin/bash
set -euo pipefail

cd /etc/raddb/certs

openssl ca -passin pass:"whatever" -config ca.cnf -revoke client_crl.pem -keyfile ca.key -cert ca.pem
openssl ca -batch -passin pass:"whatever" -gencrl -config ca.cnf -out crl/ca.crl

openssl ca -batch -passin pass:"whatever" -config ca.cnf -gencrl -keyfile ca.key -cert ca.pem -out just_crl.pem
cat ca.pem just_crl.pem > crl.pem

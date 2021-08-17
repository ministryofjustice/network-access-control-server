#!/bin/bash
set -euo pipefail

cp -pr ./test/certs_config/ocsp.cnf /etc/raddb/certs

cd /etc/raddb/certs
openssl req -new -nodes -out ocsp.csr -keyout ocsp.key -config ocsp.cnf
openssl ca -batch -in ocsp.csr -out ocsp.pem -keyfile ca.key -cert ca.pem -config ocsp.cnf -passin pass:"whatever"
openssl ocsp -port 9999 -index index.txt -rsigner ocsp.pem -rkey ocsp.key -CA ca.pem -text -out /tmp/ocsp.log &

# local verification of the certificates
# openssl ocsp -CAfile ca.pem -issuer ca.pem -cert client.pem -url http://localhost:9999 -resp_text

# revokes the certificates
# openssl ca -revoke client.pem -keyfile ca.key -cert ca.pem -config ca.cnf -passin pass:"whatever"

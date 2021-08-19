#!/bin/bash

set -e

generate_certs() {
  make
}

generate_revoked_client_certs() {
  if ! [ -f /etc/raddb/certs/revoked_client.pem ]; then
    openssl req -batch -passin pass:"whatever" -config client_crl.cnf -new -nodes -keyout client_crl.key -out client_crl.csr
    openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in client_crl.csr -out revoked_client.pem -keyfile ca.key -cert ca.pem
  fi
}

main() {
  generate_certs
  generate_revoked_client_certs
  sleep infinity
}

main

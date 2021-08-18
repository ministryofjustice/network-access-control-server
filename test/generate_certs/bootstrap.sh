#!/bin/bash

set -e

make 

if ! [ -f /etc/raddb/certs/revoked_client.pem ]; then
    openssl req -batch -passin pass:"whatever" -config client_crl.cnf -new -nodes -keyout client_crl.key -out client_crl.csr
    openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in client_crl.csr -out revoked_client.pem -keyfile ca.key -cert ca.pem
fi

sleep infinity

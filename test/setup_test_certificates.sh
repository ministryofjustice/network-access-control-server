#!/bin/bash
set -euo pipefail

cd /etc/raddb/certs

# gen eap_tls
openssl req -batch -passin pass:"whatever" -config eap_tls.cnf -new -nodes -keyout eap_tls.key -out eap_tls.csr
openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in eap_tls.csr -out eap_tls.pem -keyfile ca.key -cert ca.pem

cat eap_tls.key >> eap_tls.pem
cp eap_tls.pem /sharedcerts

# gen eap_tls_ttls
openssl req -batch -passin pass:"whatever" -config eap_tls_ttls.cnf -new -nodes -keyout eap_tls_ttls.key -out eap_tls_ttls.csr
openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in eap_tls_ttls.csr -out eap_tls_ttls.pem -keyfile ca.key -cert ca.pem

cat eap_tls_ttls.key >> eap_tls_ttls.pem
cp eap_tls_ttls.pem /sharedcerts

# gen revoked and crl
openssl req -batch -passin pass:"whatever" -config client_crl.cnf -new -nodes -keyout client_crl.key -out client_crl.csr
openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in client_crl.csr -out client_crl.pem -keyfile ca.key -cert ca.pem

cat client_crl.key >> client_crl.pem
cp client_crl.pem /sharedcerts

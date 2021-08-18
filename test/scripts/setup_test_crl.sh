#!/bin/bash
set -euo pipefail

echo "starting crl distribution point"

cd /etc/raddb/certs

openssl ca -batch -passin pass:"whatever" -gencrl -config ca.cnf -out ca.crl
openssl ca -batch -passin pass:"whatever" -config ca.cnf -gencrl -keyfile ca.key -cert ca.pem -out just_crl.pem
cat ca.pem just_crl.pem > crl.pem
cat ca.pem just_crl.pem > example_ca.crl

cp -pr /test/nginx/crl_distribution_point.conf /etc/nginx/http.d/default.conf
echo "127.0.0.1 example.com" >> /etc/hosts
echo "127.0.0.1 www.example.com" >> /etc/hosts
ls -al /etc/raddb/certs

mkdir -p /run/nginx
nginx
chown -R nginx:nginx /etc/raddb/certs/

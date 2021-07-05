#!/bin/bash
set -eo pipefail

inject_db_credentials() {
  sed -i "s/{{DB_HOST}}/${DB_HOST}/g" /etc/raddb/mods-enabled/sql
  sed -i "s/{{DB_USER}}/${DB_USER}/g" /etc/raddb/mods-enabled/sql
  sed -i "s/{{DB_PASS}}/${DB_PASS}/g" /etc/raddb/mods-enabled/sql
  sed -i "s/{{DB_NAME}}/${DB_NAME}/g" /etc/raddb/mods-enabled/sql
}

fetch_certificates() {
    if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
      cp -pr ./certs/* /etc/raddb/certs/
    else
      aws s3 sync s3://${RADIUS_CERTIFICATE_BUCKET_NAME} /etc/raddb/certs/
    fi
}

inject_ocsp_endpoint() {
  echo "${OCSP_URL}"
  sed -i "s/{{OCSP_URL}}/${OCSP_URL}/g" /etc/raddb/mods-enabled/eap

  if [ "$ENV" == "production" ]; then
    ping -c5 ${OCSP_URL}
  fi
}

begin_local_ocsp_endpoint() {
  if ! [ "$ENV" == "production" ]; then
    cp -pr ./certs/ocsp.cnf /etc/raddb/certs
    echo "starting OCSP responder"
    /scripts/ocsp_responder.sh
  fi
}

rehash_certificates() {
  echo "Rehashing certs"
  openssl rehash /etc/raddb/certs/ 
  openssl rehash /etc/raddb/certs/radsec/ 

}

begin_crl() {
  echo "starting crl distribution point"
  mkdir -p /run/nginx
  nginx 
  chown -R nginx:nginx /etc/raddb/certs/
}

# create the crl into pem, and them pem to crl binary
# openssl ca -config ../certs_conf/ca.cnf -gencrl -keyfile ca.key -cert ca.pem -out crl.pem
# openssl crl -inform PEM -in crl.pem -outform DER -out crl/example_ca.crl
# openssl ca -config ../certs_conf/ca.cnf -revoke client.pem -keyfile ca.key -cert ca.pem

echo "Starting FreeRadius"

main() {
  inject_db_credentials
  inject_ocsp_endpoint
  fetch_certificates
  rehash_certificates
  begin_local_ocsp_endpoint
}

main

/usr/sbin/radiusd -fxx -l stdout

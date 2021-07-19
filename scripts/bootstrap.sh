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

fetch_authorised_macs() {
  if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/authorised_macs /etc/raddb
  fi
}

setup_tests() {
  if [ "$ENV" == "test" ]; then
    ./test/setup_tests.sh
  fi
}

inject_ocsp_endpoint() {
  echo "${OCSP_URL}"
  sed -i "s/{{OCSP_URL}}/${OCSP_URL}/g" /etc/raddb/mods-enabled/eap
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

begin_crl_endpoint() {
  echo "starting crl distribution point"
  mkdir -p /run/nginx
  nginx 
  chown -R nginx:nginx /etc/raddb/certs/
}


echo "Starting FreeRadius"

main() {
  inject_db_credentials
  inject_ocsp_endpoint
  fetch_certificates
  fetch_authorised_macs
  setup_tests
  rehash_certificates
  begin_crl_endpoint
  begin_local_ocsp_endpoint
}

main

/usr/sbin/radiusd -fxx -l stdout

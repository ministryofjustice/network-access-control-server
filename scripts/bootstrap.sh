#!/bin/bash
set -xeo pipefail

configure_crl() {
  sed -i "s/{{ENABLE_CRL}}/${ENABLE_CRL}/g" /etc/raddb/mods-enabled/eap
}

inject_db_credentials() {
  sed -i "s/{{DB_HOST}}/${DB_HOST}/g" /etc/raddb/mods-config/python3/policyengine.py
  sed -i "s/{{DB_USER}}/${DB_USER}/g" /etc/raddb/mods-config/python3/policyengine.py
  sed -i "s/{{DB_PASS}}/${DB_PASS}/g" /etc/raddb/mods-config/python3/policyengine.py
  sed -i "s/{{DB_NAME}}/${DB_NAME}/g" /etc/raddb/mods-config/python3/policyengine.py
}

fetch_certificates() {
    if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
      cp -pr ./test/certs/* /etc/raddb/certs/
    else
      aws s3 sync s3://${RADIUS_CERTIFICATE_BUCKET_NAME} /etc/raddb/certs/
    fi
}

fetch_authorised_clients() {
  if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    mv /etc/raddb/test_clients.conf /etc/raddb/clients.conf
  else
    aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/clients.conf /etc/raddb/
  fi
}

fetch_authorised_macs() {
  if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/authorised_macs /etc/raddb
  fi
}

configure_ocsp() {
  sed -i "s/{{OCSP_URL}}/${OCSP_URL}/g" /etc/raddb/mods-enabled/eap
  sed -i "s/{{OCSP_OVERRIDE_CERT_URL}}/${OCSP_OVERRIDE_CERT_URL}/g" /etc/raddb/mods-enabled/eap
  sed -i "s/{{ENABLE_OCSP}}/${ENABLE_OCSP}/g" /etc/raddb/mods-enabled/eap
}

rehash_certificates() {
  echo "Rehashing certs"
  openssl rehash /etc/raddb/certs/ 
  openssl rehash /etc/raddb/certs/radsec/ 
}

setup_tests() {
  /test/scripts/setup_test_mac_address.sh
  /test/scripts/setup_test_crl.sh
}

echo "Starting FreeRadius"

main() {
  configure_ocsp
  inject_db_credentials
  configure_crl
  fetch_certificates
  fetch_authorised_macs
  fetch_authorised_clients
  if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    setup_tests
  fi
  rehash_certificates
}

main

/usr/sbin/radiusd -fxx -l stdout

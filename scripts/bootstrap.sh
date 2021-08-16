#!/bin/bash
set -eo pipefail

configure_crl() {
  sed -i "s/{{ENABLE_CRL}}/${ENABLE_CRL}/g" /etc/raddb/mods-enabled/eap
}

fetch_certificates() {
    if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
      cp -pr ./test/certs/* /etc/raddb/certs/
    else
      aws s3 sync s3://${RADIUS_CERTIFICATE_BUCKET_NAME} /etc/raddb/certs/
    fi
}

fetch_authorised_macs() {
  if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/authorised_macs /etc/raddb
  fi
}

inject_ocsp_endpoint() {
  echo "${OCSP_URL}"
  sed -i "s/{{OCSP_URL}}/${OCSP_URL}/g" /etc/raddb/mods-enabled/eap
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
  inject_ocsp_endpoint
  configure_crl
  fetch_certificates
  fetch_authorised_macs
  rehash_certificates
  begin_crl_endpoint
}

main

/usr/sbin/radiusd -fxx -l stdout

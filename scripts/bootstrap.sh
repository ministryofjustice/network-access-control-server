#!/bin/bash
set -eo pipefail

prefix=/etc/freeradius/3.0

configure_crl() {
  sed -i "s/{{ENABLE_CRL}}/${ENABLE_CRL}/g" $prefix/mods-enabled/eap
}

configure_ocsp() {
  sed -i "s/{{OCSP_URL}}/${OCSP_URL}/g" $prefix/mods-enabled/eap
  sed -i "s/{{OCSP_OVERRIDE_CERT_URL}}/${OCSP_OVERRIDE_CERT_URL}/g" $prefix/mods-enabled/eap
  sed -i "s/{{ENABLE_OCSP}}/${ENABLE_OCSP}/g" $prefix/mods-enabled/eap
}

inject_db_credentials() {
  sed -i "s/{{DB_HOST}}/${DB_HOST}/g" $prefix/mods-config/python3/policyengine.py
  sed -i "s/{{DB_USER}}/${DB_USER}/g" $prefix/mods-config/python3/policyengine.py
  sed -i "s/{{DB_PASS}}/${DB_PASS}/g" $prefix/mods-config/python3/policyengine.py
  sed -i "s/{{DB_NAME}}/${DB_NAME}/g" $prefix/mods-config/python3/policyengine.py
}

inject_certificate_parameters() {
  sed -i "s/{{EAP_PRIVATE_KEY_PASSWORD}}/${EAP_PRIVATE_KEY_PASSWORD}/g" $prefix/mods-enabled/eap
  sed -i "s/{{RADSEC_PRIVATE_KEY_PASSWORD}}/${RADSEC_PRIVATE_KEY_PASSWORD}/g" $prefix/sites-enabled/radsec
}
 
fetch_certificates() {
    if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
      cp -pr ./test/certs/* $prefix/certs
    else
      aws s3 sync s3://${RADIUS_CERTIFICATE_BUCKET_NAME} $prefix/certs/
    fi
}

fetch_authorised_clients() {
  if [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    cp -pr /etc/freeradius/3.0/test_clients.conf $prefix/clients.conf
  else
    aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/clients.conf $prefix
  fi
}

fetch_authorised_macs() {
  if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
    aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/authorised_macs $prefix
  fi
}

rehash_certificates() {
  echo "Rehashing certs"
  openssl rehash $prefix/certs/ 
  openssl rehash $prefix/certs/radsec/ 
}

start_packet_capture() {
  if [ "$ENABLE_PACKET_CAPTURE" == "true" ]; then
    echo "Starting packet capture for $PACKET_CAPTURE_DURATION seconds"

    mkdir ./captures
    container_id=$(curl "${ECS_CONTAINER_METADATA_URI_V4}"/task |jq -r '.TaskARN' |cut -d '/' -f 3)
    capture_file="${container_id}.pcap"
    tshark -i any -w ./captures/$capture_file -a duration:${PACKET_CAPTURE_DURATION} \
    && aws s3 sync ./captures/ s3://${RADIUS_CONFIG_BUCKET_NAME}/captures/
  fi
}

start_freeradius_server() {
  if [ "$VERBOSE_LOGGING" == "true" ]; then
    freeradius -fxx -l stdout
  else
    freeradius -f -l stdout
  fi
}

main() {
  configure_ocsp
  inject_db_credentials
  inject_certificate_parameters
  configure_crl
  fetch_certificates
  fetch_authorised_macs
  fetch_authorised_clients
  rehash_certificates
  start_packet_capture &
  start_freeradius_server
}

main

#!/bin/bash

prefix=/usr/local/etc/raddb

error_report() {
  echo "Failed to start task, error on line: $1"
  exit 1
}

fetch_certificates() {
  aws s3 sync s3://${RADIUS_CERTIFICATE_BUCKET_NAME} $prefix/certs/
}

fetch_authorised_clients() {
  aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/clients.conf $prefix
}

fetch_authorised_macs() {
  aws s3 cp s3://${RADIUS_CONFIG_BUCKET_NAME}/authorised_macs $prefix
}

report_container_health() {
  while true; do
    sleep 60
    echo "Health Check: OK"
  done
}

rehash_certificates() {
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
  /usr/local/sbin/radiusd -fxx -l stdout
}

main() {
  if ! [[ "$LOCAL_DEVELOPMENT" == "true" ]]; then
    fetch_certificates
    fetch_authorised_macs
    fetch_authorised_clients
  fi

  rehash_certificates
  report_container_health &
  start_packet_capture &
  start_freeradius_server
}

trap "error_report" ERR SIGTERM EXIT

main

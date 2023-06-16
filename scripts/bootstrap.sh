#!/bin/bash

prefix=/usr/local/etc/raddb
certs_expiring_count=0

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

report_certificate_expiry() {
  while true; do
    sleep 3600
    certs_expiring_count=0
    echo "Certificate Expiry Check Running..."
    check_cert_expiry $prefix/certs
    check_cert_expiry $prefix/certs/radsec
    echo "Certificate Expiry Check Completed. Number of Certificates Expiring = $certs_expiring_count"
  done
}

check_cert_expiry() {
  bad_certificates=()

  # Loop through all the certificates in the directory
  while IFS= read -r -d '' cert; do
    echo "$cert"
    # Extract the expiry date of the certificate
    expiry_date=$(openssl x509 -enddate -noout -in "$cert" | awk -F "=" '{print $2}')
    openssl_exit_code=$?
    if [ $openssl_exit_code -eq 0 ]; then
      echo "$expiry_date"
      # Convert the expiry date to a Unix timestamp
      expiry_timestamp=$(date -d "${expiry_date}" -D "%B %d %H:%M:%S %Y" +%s)
      echo "$expiry_timestamp"

      # Calculate the number of seconds in four months
      four_months=$((4 * 30 * 24 * 60 * 60))

      # Calculate the timestamp for four months from now
      four_months_from_now=$(($(date +%s) + $four_months))
      echo "$four_months_from_now"

      # Check if the certificate is expiring in the next four months
      if [ $expiry_timestamp -lt $four_months_from_now ]; then
        # If the certificate is expiring soon, add it to the expiring_certificates array
        expiring_certificates+=("$cert")
        ((certs_expiring_count++))
        echo "Expiring Certificate: $cert is expiring on $expiry_date"
      fi
    else
      # If the certificate is invalid or cannot be read, add it to the bad_certificates array
      bad_certificates+=("$cert")
    fi
  done < <(find "$1" -maxdepth 1 -type f -name "*.pem" ! -name "01.pem" ! -name "02.pem" ! -name "ca.pem" ! -name "client.pem" ! -name "user@example.org.pem" -print0)

  # Report on bad certificates
  if [ ${#bad_certificates[@]} -gt 0 ]; then
    echo "Warning: The following certificates are considered bad or cannot be read:"
    for cert in "${bad_certificates[@]}"; do
      echo "$cert"
    done
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
  report_certificate_expiry &
  start_freeradius_server
}

trap "error_report" ERR SIGTERM EXIT

main
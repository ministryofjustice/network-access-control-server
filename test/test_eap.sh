#!/bin/bash

set -x

test_eap_tls() {
  cp ./sharedcerts/eap_tls.pem /etc/raddb/certs

  eapol_test -r0 -t3 -c /test/eapol_test_tls.conf -a 10.5.0.5 -s testing

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_eap_tls_with_unauthorised_client() {
  cp ./sharedcerts/eap_tls.pem /etc/raddb/certs

  unauthorised_client_ip_address="10.55.20.16"

  request=$(eapol_test -r0 -t3 -c /test/eapol_test_tls.conf -a 10.5.0.5 -A ${unauthorised_client_ip_address} -s testing)

  expect_unauthenticated_response "$request" "One mismatch due to unauthorised client [252]"
}

test_eap_tls_ttls() {
  cp ./sharedcerts/eap_tls_ttls.pem /etc/raddb/certs

  eapol_test -r0 -t3 -c /test/eapol_test_tls_ttls.conf -a 10.5.0.5 -s testing

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_eap_tls_ttls_with_unauthorised_client() {
  cp ./sharedcerts/eap_tls_ttls.pem /etc/raddb/certs

  unauthorised_client_ip_address="10.55.20.16"

  request=$(eapol_test -r0 -t3 -c /test/eapol_test_tls_ttls.conf -a 10.5.0.5 -A ${unauthorised_client_ip_address} -s testing)

  expect_unauthenticated_response "$request" "One mismatch due to unauthorised client [252]"
}


test_mab() {
  eapol_test -r0 -t3 -c /test/eapol_test_mab.conf -a 10.5.0.5 -s testing -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55 #custom attr Called-Station-Id 

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_mab_with_unauthorised_mac_address() {
  unauthorised_mac_address="55:44:33:22:11:00"

  request=$(eapol_test -r0 -t3 -c /test/eapol_test_mab.conf -a 10.5.0.5 -s testing -M ${unauthorised_mac_address} -N30:s:55-44-33-22-11-00) #custom attr Called-Station-Id 

  expect_unauthenticated_response "$request" "One mismatch due to unauthorised MAC address [252]"
}

test_crl() {
  cp ./sharedcerts/client_crl.pem /etc/raddb/certs

  request=$(eapol_test -r0 -t3 -c /test/eapol_test_crl.conf -a 10.5.0.5 -s testing)

  expect_unauthenticated_response "$request" "One mismatch due to revoked certificate [252]"
}

test_radsecproxy() {
  cp ./sharedcerts/radsecproxy.pem /etc/raddb/certs

  eapol_test -r0 -t3 -c /test/eapol_test_radsecproxy.conf -a 10.5.0.6 -A 10.5.0.8 -p2083 -s radsec

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

expect_unauthenticated_response() {
  if [[ $1 && $? == 252 ]]; then
    IFS= # IFS is set explicitly to blank; allowing new line characters to be escaped
    request="$1"
    message="$2"

    echo ${request//FAILURE/SUCCESS: $message}
  fi
}

main() {
  # test_eap_tls
  # test_eap_tls_with_unauthorised_client
  # test_eap_tls_ttls
  # test_eap_tls_ttls_with_unauthorised_client
  # test_mab
  # test_mab_with_unauthorised_mac_address
  # test_crl
  test_radsecproxy
}

main

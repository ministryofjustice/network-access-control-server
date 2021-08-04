#!/bin/bash

set -x

test_eap_tls() {
  cp ./sharedcerts/eap_tls.pem /etc/raddb/certs

  eapol_test -r0 -t3 -c /test/eapol_test_tls.conf -a 10.5.0.5 -s testing

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_eap_tls_ttls() {
  cp ./sharedcerts/eap_tls_ttls.pem /etc/raddb/certs

  eapol_test -r0 -t3 -c /test/eapol_test_tls_ttls.conf -a 10.5.0.5 -s testing

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_mab() {
  eapol_test -r0 -t3 -c /test/eapol_test_mab.conf -a 10.5.0.5 -s testing -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55 #custom attr Called-Station-Id 

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_crl() {
  cp ./sharedcerts/client_crl.pem /etc/raddb/certs

  test_revoked_certificate=$(eapol_test -r0 -t3 -c /test/eapol_test_crl.conf -a 10.5.0.5 -s testing)

  if [[ $test_revoked_certificate && $? == 252 ]]; then
    echo "${test_revoked_certificate//FAILURE/SUCCESS: One mismatch due to revoked certificate [252]}"
  else
    exit $?
  fi
}

main() {
  test_eap_tls
  test_eap_tls_ttls
  test_mab
  test_crl
}

main

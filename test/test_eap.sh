#!/bin/bash

set -ex

test_eap_ttls() {
  eapol_test -r0 -t3 -c eapol_test_ttls.conf -a 10.5.0.5 -s testing -p1812 \
  -M 00:11:22:33:44:55 \
  -N30:s:zzzzzzzzzzz #custom attr Called-Station-Id
}

test_eap_tls() {
  eapol_test -r0 -t3 -c eapol_test.conf -a 10.5.0.5 -s testing \
  -M 00:11:22:33:44:55 \
  -N30:s:zzzzzzzzzzz #custom attr Called-Station-Id 
}

test_eap_tls_ttls() {
  eapol_test -r0 -t3 -c eapol_test_tls_ttls.conf -a 10.5.0.5 -s testing \
  -M 00:11:22:33:44:55 \
  -N30:s:zzzzzzzzzzz #custom attr Called-Station-Id 
}

main() {
  test_eap_tls
  test_eap_ttls
  test_eap_tls_ttls
}

main

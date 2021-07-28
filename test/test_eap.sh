#!/bin/bash

set -xe

test_eap_tls() {
  eapol_test -r0 -t3 -c /test/eapol_test_tls.conf -a 10.5.0.5 -s testing
}

main() {
  test_eap_tls
}

main

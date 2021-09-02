#!/bin/bash

set -ex

setup_test_matching_policy() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < /test/policy_engine_data/test_matching_policy.sql
}

test_matching_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing \
  -M 00:11:22:33:44:55 \
  -N 30:s:00-11-22-33-44-55 
}

main() {
  setup_test_matching_policy
  test_matching_policy >> /results
}

main

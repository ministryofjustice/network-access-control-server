#!/bin/bash

set -ex

setup_test_matching_policy() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < /test/policy_engine_data/test_matching_policy.sql
}

test_matching_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing
}


test_fallback_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing \
  -N4:x:0x0a090807 # random octet IP address to cause fallback to initiate 
}


assert_policy_result() {
  cat /integration-results |grep "Attribute 64 (Tunnel-Type) length=6"
  cat /integration-results |grep "Value: 0000000d"
  cat /integration-results |grep "Attribute 65 (Tunnel-Medium-Type) length=6"
  cat /integration-results |grep "Value: 00000006"
  cat /integration-results |grep "Attribute 81 (Tunnel-Private-Group-Id) length=5"
  cat /integration-results |grep "Value: 373737"

  if [ $? != 0 ]; then
    exit $?
  fi
}

assert_fallback_policy_result() {
  cat /integration-results |grep "Attribute 18 (Reply-Message) length=17"
  cat /integration-results |grep "Value: 'Fallback Policy'"

  if [ $? != 0 ]; then
    exit $?
  fi
}

main() {
  setup_test_matching_policy
  test_matching_policy > /integration-results
  assert_policy_result
  
  test_fallback_policy > /integration-results
  assert_fallback_policy_result
}

main

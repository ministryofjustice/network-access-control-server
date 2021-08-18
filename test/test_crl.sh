#!/bin/bash

set -x

expect_unauthenticated_response() {
  if [[ $1 && $? == 252 ]]; then
    IFS= # IFS is set explicitly to blank; allowing new line characters to be escaped
    request="$1"
    message="$2"

    echo ${request//FAILURE/SUCCESS: $message}
  fi
}

request=$(eapol_test -r0 -t3 -c /test/config/eapol_test_crl.conf -a 10.5.0.5 -s testing)
expect_unauthenticated_response "$request" "One mismatch due to revoked certificate [252]"
echo "done"
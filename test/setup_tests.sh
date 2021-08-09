#!/bin/bash
set -euo pipefail

if [ "$CONTAINER_NAME" == "server" ]; then
    ./test/setup_authorised_clients.sh

    ./test/setup_test_mac_address.sh
    
    ./test/setup_test_certificates.sh

    ./test/setup_test_crl.sh

    ./test/radsecproxy.sh
fi

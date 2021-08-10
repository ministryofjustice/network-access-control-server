#!/bin/bash

set -ex

cat > ../etc/raddb/clients.conf << EOF 
client test_client {
    ipaddr = 10.5.0.6
    shortname = test_client
    secret = testing
}

EOF

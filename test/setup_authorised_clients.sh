#!/bin/bash

set -ex

cat > ../etc/raddb/clients.conf << EOF 
client test_client {
    ipaddr = 10.5.0.6
    shortname = test_client
    secret = testing
}

client radsec_client {
    ipaddr = 10.5.0.8
    shortname = radsec_client
    secret = radsec
    virtual_server = radsec
}
EOF

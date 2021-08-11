#! /bin/bash
set -e

# Start Radsecproxy
if [ "$CONTAINER_NAME" == "radsecproxy" ]; then
    cp ./sharedcerts/eap_tls.pem /etc/raddb/certs
    /sbin/radsecproxy -c /etc/radsecproxy.conf -i /var/run/radsecproxy.pid
fi

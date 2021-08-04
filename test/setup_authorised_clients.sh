#!/bin/bash

set -ex

echo "" > ../etc/raddb/clients.conf
echo "client test_client {" >> ../etc/raddb/clients.conf
echo "    ipaddr = 10.5.0.6" >> ../etc/raddb/clients.conf
echo "    shortname = test_client" >> ../etc/raddb/clients.conf
echo "    secret = testing" >> ../etc/raddb/clients.conf
echo "}" >> ../etc/raddb/clients.conf

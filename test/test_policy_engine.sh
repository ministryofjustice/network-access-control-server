#!/bin/bash

set -ex

setup_test_matching_policy() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < ./policy_engine_data/test_matching_policy.sql
}

#(('User-Name', 'anonymous@example.com'), ('NAS-IP-Address', '127.0.0.1'), ('Calling-Station-Id', '00-11-22-33-44-55'), ('Framed-MTU', '1400'), ('NAS-Port-Type', 'Wireless-802.11'), ('Service-Type', 'Framed-User'), ('Connect-Info', 'CONNECT 11Mbps 802.11b'), ('Called-Station-Id', '00-11-22-33-44-55'), ('EAP-Message', '0x0239005315001703030048844626869c36a9f0e31bf95b9ab8b67a0ce937ff0c33b7a49b372db17ce170897aef697f212091e766602edb1feb879ef4200e92abdb19a532664749ed9c7aa55fa38a77dd62a89e'), ('State', '0xfdcf113ff9f604b9170081a50234ec38'), ('Message-Authenticator', '0x02a0af5a965399e308e49d0acf4df8e4'), ('Event-Timestamp', 'Sep  1 2021 15:35:00 UTC'), ('EAP-Type', 'TTLS'), ('Client-Shortname', 'test_client'))

test_matching_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing \
  -M 00:11:22:33:44:55 \
  -N 30:s:00-11-22-33-44-55 #custom attr Called-Station-Id 
}

main() {
  # setup_test_matching_policy
  test_matching_policy
}

main

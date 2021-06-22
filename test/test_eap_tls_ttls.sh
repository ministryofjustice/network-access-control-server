#!/bin/bash

set -ex

eapol_test -r0 -t3 -c eapol_test_tls_ttls.conf -a 127.0.0.1 -s testing -A 127.0.0.3 \
-M 00:11:22:33:44:55 \
-N30:s:zzzzzzzzzzz #custom attr Called-Station-Id 
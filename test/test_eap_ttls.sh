#!/bin/bash

set -ex

eapol_test -r0 -t3 -c eapol_test_ttls.conf -a 10.5.0.5 -s testing -p1812 \
-M 00:11:22:33:44:55 \
-N30:s:zzzzzzzzzzz #custom attr Called-Station-Id

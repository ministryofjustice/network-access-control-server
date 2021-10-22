#/bin/bash

set -e

if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
  groupadd wireshark \
  && usermod -a -G wireshark freerad \
  && newgrp wireshark \
  && chgrp wireshark /usr/bin/dumpcap \
  && chmod 750 /usr/bin/dumpcap \
  && setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
fi
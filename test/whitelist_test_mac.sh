#!/bin/bash

set -ex
  
echo "00-11-22-33-44-55" >> /etc/raddb/authorised_macs
echo "        Reply-Message = \"Device with MAC Address %{Calling-Station-Id} authorized for network access\"" >> /etc/raddb/authorised_macs

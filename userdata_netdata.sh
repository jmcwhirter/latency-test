#!/bin/bash

# Download Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
# Download fping
/usr/libexec/netdata/plugins.d/fping.plugin install

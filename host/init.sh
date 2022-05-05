#!/bin/bash

subscription-manager release --set=7Server
subscription-manager repos --enable=*

cat <<'STOPP' | tee /tmp/attachHost.sh
${host_script}
STOPP

sudo nohup bash /tmp/attachHost.sh &



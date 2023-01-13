#!/bin/bash

subscription-manager release --set=8
subscription-manager repos --disable='*eus*'

cat <<'STOPP' | tee /tmp/attachHost.sh
${host_script}
STOPP

sudo nohup bash /tmp/attachHost.sh &


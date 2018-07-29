#!/bin/bash
#
# A script that releases nodes from a SSID file written by

set +x
export CICO_API_KEY="$(<~/duffy.key)"
set -x

SSID_FILE=${SSID_FILE:-$WORKSPACE/cico-ssid}

for ssid in $(cat ${SSID_FILE})
do
    cico -q node done $ssid
done

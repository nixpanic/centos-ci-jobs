#!/bin/bash
#
# Request ${NODE_COUNT} number of systems
#  - provisioned with CentOS ${CENTOS_RELEASE}
#  - on ${CENTOS_ARCH}
#
# Based on get-node.sh from github.com/gluster/centosci.
#
set +x

# Defaults for cico
CENTOS_RELEASE=${CENTOS_RELEASE:-7}
CENTOS_ARCH=${CENTOS_ARCH:-x84_64}
NODE_COUNT=${NODE_COUNT:-1}

HOSTS_FILE=${HOSTS_FILE:-$WORKSPACE/hosts}
SSID_FILE=${SSID_FILE:-$WORKSPACE/cico-ssid}

# Remove any files that may have been leftover from previous runs
rm -f ${HOSTS_FILE} ${SSID_FILE}

# Request the nodes from Duffy
nodes=$(cico -q node get --release ${CENTOS_RELEASE} --arch ${CENTOS_ARCH} --count ${NODE_COUNT} --column hostname --column ip_address --column comment -f value)
cico_ret=$?

# Fail in case cico returned an error, or no nodes at all
if [ ${cico_ret} -ne 0 ]
then
    echo "cico returned an error (${cico_ret})" >/dev/stderr
    exit 2
elif [ -z "${nodes}" ]
    echo "cico failed to return any systems" >/dev/stderr
    exit 2
fi

# Write nodes to inventory file and persist the SSID separately for simplicity
touch ${SSID_FILE}
IFS=$'\n'
for node in ${nodes}
do
    host=$(echo "${node}" |cut -f1 -d " ")
    address=$(echo "${node}" |cut -f2 -d " ")
    ssid=$(echo "${node}" |cut -f3 -d " ")

    line="${address}"
    echo "${line}" >> ${HOSTS_FILE}

    # Write unique SSIDs to the SSID file
    if ! grep -q ${ssid} ${SSID_FILE}; then
        echo ${ssid} >> ${SSID_FILE}
    fi
done

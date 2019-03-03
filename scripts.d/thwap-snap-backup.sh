#!/bin/sh

THWAP_BASE_CFG=${HOME}/.thwap/init.d/thwap.sh
test -f ${THWAP_BASE_CFG} && . ${THWAP_BASE_CFG} || (echo "No ${THWAP_BASE_CONFIG}";exit 1)

CONFIG=${THWAP_CONF}/thwap-snap-backup.sh
if test -f ${CONFIG}; then
    . ${CONFIG}
    tar ${THWAP_SNAPS_ARGS} 2>/dev/null | ${THWAP_SNAPS_COMP} >${THWAP_SNAPS_CURRENT}
    current_snaps=$(ls ${THWAP_SNAPS}|sort|wc -l)
    del_num=$((${current_snaps} - ${THWAP_SNAPS_HISTORY}))
    if test ${current_snaps} -gt ${THWAP_SNAPS_HISTORY}; then
        cdir=$(pwd)
        cd ${THWAP_SNAPS};ls $(hostname -s)*|sort|head -n ${del_num}|xargs rm -f
        cd ${cdir}
    fi
else
    echo "No configuration found at: ${CONFIG}"
fi



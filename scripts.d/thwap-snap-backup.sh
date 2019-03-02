#!/bin/sh

# Thwap backup configuration, start with the base dir
THWAP_BKUP=/backup/${USER}

# and our tar snapshot stuff
THWAP_SNAPS=${THWAP_BKUP}/snaps
THWAP_SNAPS_ARGS="-f- -c ${HOME}/"
THWAP_SNAPS_COMP="pxz -e -9"
THWAP_SNAPS_EXT="txz"
THWAP_SNAPS_HISTORY=7

snap_name=${THWAP_SNAPS}/$(hostname)-${USER}-$(date +%s).${THWAP_SNAPS_EXT}
tar ${THWAP_SNAPS_ARGS} 2>/dev/null | ${THWAP_SNAPS_COMP} >${snap_name}
current_snaps=$(ls ${THWAP_SNAPS}|sort|wc -l)
del_num=$((${current_snaps} - ${THWAP_SNAPS_HISTORY}))
if test ${current_snaps} -gt ${THWAP_SNAPS_HISTORY}; then
    cdir=$(pwd)
    cd ${THWAP_SNAPS};ls|sort|head -n ${del_num}|xargs rm -f
    cd ${cdir}
fi

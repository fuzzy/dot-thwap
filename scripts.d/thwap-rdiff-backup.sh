#!/bin/sh

CONFIG=${THWAP_CONF}/thwap-rdiff-backup.sh
if test -f ${CONFIG}; then
    . ${CONFIG}
    rdiff-backup ${THWAP_RDIFF_ARGS} ${HOME}/ ${THWAP_RDIFF_DIR}/
    rdiff-backup --remove-older-than ${THWAP_RDIFF_RETENTION} ${THWAP_RDIFF_DIR}
else
    echo "No configuration found at: ${CONFIG}"
fi


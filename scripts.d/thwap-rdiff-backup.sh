#!/bin/sh

THWAP_BASE_CFG=${HOME}/.thwap/init.d/thwap.sh
test -f ${THWAP_BASE_CFG} && . ${THWAP_BASE_CFG} || (echo "No ${THWAP_BASE_CONFIG}";exit 1)

CONFIG=${THWAP_CONF}/thwap-rdiff-backup.sh
if test -f ${CONFIG}; then
    . ${CONFIG}
    rdiff-backup ${THWAP_RDIFF_ARGS} ${HOME}/ ${THWAP_RDIFF_DIR}/
    rdiff-backup --remove-older-than ${THWAP_RDIFF_RETENTION} ${THWAP_RDIFF_DIR}
else
    echo "No configuration found at: ${CONFIG}"
fi


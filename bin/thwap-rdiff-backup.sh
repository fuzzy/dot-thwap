#!/bin/sh

THWAP_BASE_CFG=${HOME}/.thwap/init.d/thwap.sh
test -f ${THWAP_BASE_CFG} && . ${THWAP_BASE_CFG} || (echo "No ${THWAP_BASE_CONFIG}";exit 1)

CONFIG=${THWAP_CONF}/thwap-rdiff-backup.sh
if test -f ${CONFIG}; then
    . ${CONFIG}
    tout "\033[32m>>> \033[1;37mDelta backup\033[0m\n"
    date_l="\033[0m\033[37mDate: \033[1;37m$(date +%F_%T)\033[0m"
    dir_l="\033[37mDir: \033[1;37m${HOME}\033[0m"
    ret_l="\033[0m\033[37mPruning backups older than \033[1;37m${THWAP_RDIFF_RETENTION}"
    thwap_exec "${date_l} ${dir_l}" "rdiff-backup ${THWAP_RDIFF_ARGS} ${HOME}/ ${THWAP_RDIFF_DIR}/"
    thwap_exec "${ret_l}" "rdiff-backup --remove-older-than ${THWAP_RDIFF_RETENTION} ${THWAP_RDIFF_DIR}"
else
    echo "No configuration found at: ${CONFIG}"
fi


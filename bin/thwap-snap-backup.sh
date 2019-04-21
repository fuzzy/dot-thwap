#!/bin/sh

purge_snaps() {
    ls $(hostname -s)*|sort|head -n ${del_num}|xargs rm -f
}

THWAP_BASE_CFG=${HOME}/.thwap/init.d/thwap.sh
test -f ${THWAP_BASE_CFG} && . ${THWAP_BASE_CFG} || (echo "No ${THWAP_BASE_CONFIG}";exit 1)

CONFIG=${THWAP_CONF}/thwap-snap-backup.sh
if test -f ${CONFIG}; then
    . ${CONFIG}
    OUTF=${THWAP_SNAPS}/${THWAP_SNAPS_CURRENT}
    tar_cmd="sudo ${TTAR} -f${OUTF} ${THWAP_SNAPS_ARGS}"

    # output formatting
    tout "\033[32m>>> \033[1;37mSnapshot backup\033[0m\n"
    date_l="\033[0m\033[37mDate: \033[1;37m${THWAP_SNAPS_DATE}\033[0m"
    dir_l="\033[37mDir: \033[1;37m${HOME}\033[0m"
    comp_l="\033[0m\033[37mCompressing: \033[1;37m${THWAP_SNAPS_COMP_T}\033[0m"
    hist_l="\033[37m# of snapshots kept: \033[1;37m${THWAP_SNAPS_HISTORY}\033[0m"

    # do the thing
    thwap_exec "${date_l} ${dir_l}" "${tar_cmd}" && \
        thwap_exec "${comp_l} ${hist_l}" "${THWAP_SNAPS_COMP} ${OUTF}" && \
        sudo rm -f ${OUTF}
    current_snaps=$(ls ${THWAP_SNAPS}|sort|wc -l)
    del_num=$((${current_snaps} - ${THWAP_SNAPS_HISTORY}))
    if test ${current_snaps} -gt ${THWAP_SNAPS_HISTORY}; then
        cdir=$(pwd)
        cd ${THWAP_SNAPS};
        thwap_exec "Pruning old backups" "purge_snaps"
        cd ${cdir}
    fi
else
    echo "No configuration found at: ${CONFIG}"
fi

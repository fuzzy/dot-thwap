THWAP_OS=$(uname -s)
THWAP_ARCH=$(uname -m)
THWAP_BASE=${HOME}/.thwap
THWAP_LIBR=${THWAP_BASE}/library
THWAP_HOME=${THWAP_LIBR}/${THWAP_OS}/${THWAP_ARCH}
THWAP_TEMP=${THWAP_HOME}/temp
THWAP_PKGD=${THWAP_BASE}/pkg.d

alias thwap_rdiff_backup="${HOME}/.thwap/scripts.d/thwap-rdiff-backup.sh"
alias thwap_snap_backup="${HOME}/.thwap/scripts.d/thwap-snap-backup.sh"

thwap_backup() {
    thwap_rdiff_backup
    thwap_snap_backup
}

for i in ${THWAP_BASE} ${THWAP_HOME} ${THWAP_LIBR} \
                       ${THWAP_TEMP} ${THWAP_PKGD}; do
    test ! -d ${i} && mkdir -p ${i}
done

add2path() {
    if test -d ${1} && test -z "$(echo ${PATH}|grep ${1})"; then
        export PATH=${1}:${PATH}
    fi
}

chpy() {
    PYDFLT=${THWAP_HOME}/python/default
    case "${1}" in
        (2) PYTARG=${THWAP_HOME}/python/2   ;;
        (3) PYTARG=${THWAP_HOME}/python/3   ;;
        (*) PYTARG=${THWAP_HOME}/python/3   ;; # default
    esac
    rm -f ${PYDFLT}
    ln -sf ${PYTARG} ${PYDFLT}
    PYPATH=${PYDFLT}/bin
    add2path ${PYPATH}
}

for itm in ${THWAP_BASE}/pkg.d/*.sh; do
    test -f ${itm} && . ${itm}
done



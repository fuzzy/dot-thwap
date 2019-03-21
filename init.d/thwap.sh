THWAP_OS=$(uname -s)
THWAP_ARCH=$(uname -m)
THWAP_BASE=${HOME}/.thwap
THWAP_INIT=${THWAP_BASE}/init.d
THWAP_LIBR=${THWAP_BASE}/library
THWAP_HOME=${THWAP_LIBR}/${THWAP_OS}/${THWAP_ARCH}
THWAP_TEMP=${THWAP_HOME}/temp
THWAP_PKGD=${THWAP_BASE}/pkg.d
THWAP_CONF=${THWAP_BASE}/etc.d


. ${THWAP_INIT}/thwap-alias.sh
. ${THWAP_INIT}/thwap-lib.sh
. ${THWAP_INIT}/thwap-platform.sh

for i in ${THWAP_BASE} ${THWAP_HOME} ${THWAP_LIBR} \
                       ${THWAP_TEMP} ${THWAP_PKGD}; do
    test ! -d ${i} && mkdir -p ${i}
done

case "$-" in
    (*i*)
        for itm in ${THWAP_BASE}/pkg.d/*.sh; do
            test -f ${itm} && . ${itm}
        done
        ;;
esac




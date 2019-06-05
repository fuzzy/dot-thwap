THWAP_OS=$(uname -s)
THWAP_ARCH=$(uname -m)

THWAP_BASE=${HOME}/.thwap
THWAP_CONF=${THWAP_BASE}/etc
THWAP_INIT=${THWAP_CONF}/init.d
THWAP_LIBR=${THWAP_BASE}/usr
THWAP_HOME=${THWAP_LIBR}/${THWAP_OS}/${THWAP_ARCH}
THWAP_TEMP=${THWAP_BASE}/temp
THWAP_PKGD=${THWAP_BASE}/splats
THWAP_EXEC=${THWAP_BASE}/bin
THWAP_SHARE=${THWAP_BASE}/share

source ${THWAP_INIT}/thwap-alias.sh
source ${THWAP_INIT}/thwap-lib.sh
source ${THWAP_INIT}/thwap-platform.sh

for i in ${THWAP_HOME} ${THWAP_TEMP}; do
    test ! -d ${i} && mkdir -p ${i}
done

test -f ${THWAP_INIT}/thwap-lua.sh && source ${THWAP_INIT}/thwap-lua.sh
case "$-" in
    (*i*)
        for dir in $(${THWAP_EXEC}/thwap.lua); do
            add2path ${dir}
        done
        ;;
    (*)
        for dir in $(${HOME}/thwap.lua); do
            add2path ${dir} 2>/dev/null
        done
        ;;
esac




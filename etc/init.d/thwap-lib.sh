
thwap_backup() {
    thwap_rdiff_backup
    thwap_snap_backup
}

add2path() {
    if test -d ${1} && test -z "$(echo ${PATH}|grep ${1})"; then
        export PATH=${1}:${PATH}
    fi
}

tout() {
    case "$-" in
        (*i*) printf "${*}" >/dev/stderr ;;
    esac
}

thwap_exec() {
    S_PASS="\033[1;32mOK\033[0m"
    S_FAIL="\033[1;31mERR\033[0m"
    OUTPUT="${THWAP_TEMP}/thwap_exec.log"
    tout "\033[1;32m>>>\033[0m ${1}: "
    ${2} >${OUTPUT} 2>&1 && tout "${S_PASS}\n" || (tout "${S_FAIL}\n"; \
                                                   NOUTPUT=${THWAP_TEMP}-$(openssl rand -hex 8).log; \
                                                   mv ${OUTPUT} ${NOUTPUT}; \
                                                   tout "See ${NOUTPUT}\n")
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

thwap_direnv() {
    if test "${PWD}" != "${THWAP_LAST_DIR}"; then
        test -f ${PWD}/.thwapenv && . ${PWD}/.thwapenv
    fi
    export THWAP_LAST_DIR=${PWD}
}

export THWAP_LAST_DIR=${HOME}
export PROMPT_COMMAND=thwap_direnv

build_py() {
    if test ! -x ${THWAP_HOME}/python/${pyvers}/bin/${pyexec}; then
        tout "\033[32m>>>\033[0m PKG: \033[36mPython ${pyvers}\033[0m\n"
        cd ${THWAP_TEMP}
        thwap_exec "Fetching" "wget -cq ${url}"
        thwap_exec "Extracting" "tar -Jxf ${tball}"
        cd Python-${pyvers}
        thwap_exec "Configuring" "./configure --prefix=${THWAP_HOME}/python/${pyvers} ${build_args}"
        thwap_exec "Compiling" "${TMAKE} -j${NCPUS}"
        thwap_exec "Installing" "make install" && cd ../ && rm -rf Python-${pyvers}*
        pymajor=$(echo ${pyvers}|awk -F. '{print $1}')
        ln -sf ${THWAP_HOME}/python/${pyvers} ${THWAP_HOME}/python/${pymajor}
        cd
        test "${pymajor}" = "3" && PIP=pip3 || PIP=pip
        reqs=${THWAP_PKGD}/py${pymajor}-requirements.txt
        thwap_exec "Installing extra packages" "${PIP} install --upgrade -r ${reqs}"
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

# Python 3.x setup
pyexec=python3
pyvers=3.7.2
tball=Python-${pyvers}.tar.xz
url="https://www.python.org/ftp/python/${pyvers}/${tball}"
build_args="--with-ensurepip=upgrade"
reqs="${THWAP_PKGD}/py3-requirements.txt"
build_py

# Python 2.x setup
pyexec=python
pyvers=2.7.15
tball=Python-${pyvers}.tar.xz
url="https://www.python.org/ftp/python/${pyvers}/${tball}"
build_args="--with-ensurepip=upgrade --with-signal-module --with-fpectl --with-threads"
reqs="${THWAP_PKGD}/py2-requirements.txt"
build_py

# default to 3.x

chpy 3

case "$(uname -s)" in
    (FreeBSD)
        tmake=$(which gmake)
        PROC_CPU="/compat/linux/proc/cpuinfo"
        ;;
    (Linux)
        tmake=$(which make)
        PROC_CPU="/proc/cpuinfo"
        ;;
esac

build_py() {
    if test ! -x ${THWAP_HOME}/python/${pyvers}/bin/${pyexec}; then
        cd ${THWAP_TEMP}
        wget ${url}
        tar -Jxf ${tball}
        cd Python-${pyvers}
        ./configure --prefix=${THWAP_HOME}/python/${pyvers} ${build_args} && \
            ${tmake} -j$(grep rocess ${PROC_CPU}|wc -l) && \
            make install && cd ../ && rm -rf Python-${pyvers}*
        pymajor=$(echo ${pyvers}|awk -F. '{print $1}')
        ln -sf ${THWAP_HOME}/python/${pyvers} ${THWAP_HOME}/python/${pymajor}
        cd
    fi
}

# Python 3.x setup
pyexec=python3
pyvers=3.7.2
tball=Python-${pyvers}.tar.xz
url="https://www.python.org/ftp/python/${pyvers}/${tball}"
build_args="--with-ensurepip=upgrade"

build_py && chpy 3 && pip3 install --upgrade -r ${THWAP_PKGD}/py3-requirements.txt >/dev/null 2>&1

# Python 2.x setup
pyexec=python
pyvers=2.7.15
tball=Python-${pyvers}.tar.xz
url="https://www.python.org/ftp/python/${pyvers}/${tball}"
build_args="--with-ensurepip=upgrade --with-signal-module --with-fpectl --with-threads"

build_py && chpy 2 && pip install --upgrade -r ${THWAP_PKGD}/py2-requirements.txt >/dev/null 2>&1

# default to 3.x

chpy 3

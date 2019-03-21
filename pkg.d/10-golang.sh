
vers=1.10.8
tball=go${vers}.src.tar.gz
url=https://dl.google.com/go/${tball}

case "$(uname -s)" in
    (FreeBSD)
        case "$(uname -m)" in
            (arm64) SKIP_PLATFORM=1 ;;
        esac
        ;;
esac

if test -z "${SKIP_PLATFORM}"; then
    if test ! -x ${THWAP_HOME}/golang/root/bin/go; then
        tout "\033[32m>>>\033[0m PKG: \033[36mGoLang ${vers}\033[0m\n"
        cd ${THWAP_TEMP} ; thwap_exec "Fetching" "$(which wget) -qc ${url}"
        test ! -d ${THWAP_HOME}/golang/path && mkdir -p ${THWAP_HOME}/golang/path
        thwap_exec "Extracting" "tar -zxf ${tball}"
        mv ${THWAP_TEMP}/go ${THWAP_HOME}/golang/${vers}
        cd ${THWAP_HOME}/golang && ln -sf ${THWAP_HOME}/golang/${vers} root
        if test -x /usr/bin/go; then
            cd ${THWAP_HOME}/golang/root/src
            thwap_exec "Building" "env GOROOT_BOOTSTRAP=${GOROOT_BOOTSTRAP} ./make.bash"
        fi
        cd
        rm -f ${THWAP_TEMP}/${tball}
        for pkg in $(cat ${THWAP_CONF}/golang-packages.sh); do
	          executable=$(echo ${pkg}|awk -F: '{print $1}')
	          instroot=$(echo ${pkg}|awk -F: '{print $2}')
            if test ! -x ${GOPATH}/bin/${executable}; then
                thwap_exec "go get: ${executable}" "go get -v -u ${instroot}"
            fi
        done
    fi

    export GOROOT=${THWAP_HOME}/golang/root
    export GOPATH=${THWAP_HOME}/golang/path

    add2path ${GOROOT}/bin
    add2path ${GOPATH}/bin

fi




vers=1.10.8
tball=go${vers}.src.tar.gz
url=https://dl.google.com/go/${tball}

case "$(uname -s)" in
    (FreeBSD)
        GOROOT_BOOTSTRAP=/usr/local/go
        ;;
    (Linux)
        GOROOT_BOOTSTRAP=/usr/lib/go
        ;;
esac

if test ! -x ${THWAP_HOME}/golang/root/bin/go; then
    echo "Fetching ${vers} from ${url}"
    cd ${THWAP_TEMP} ; wget ${url}
    test ! -d ${THWAP_HOME}/golang/path && mkdir -p ${THWAP_HOME}/golang/path
    tar -zxf ${tball} && sleep 2 && mv -v ${THWAP_TEMP}/go ${THWAP_HOME}/golang/${vers}
    cd ${THWAP_HOME}/golang && ln -sf ${THWAP_HOME}/golang/${vers} root
    if test -x /usr/bin/go; then
        cd ${THWAP_HOME}/golang/root/src && env GOROOT_BOOTSTRAP=${GOROOT_BOOTSTRAP} ./make.bash
    fi
    cd
    rm -f ${THWAP_TEMP}/${tball}
fi

export GOROOT=${THWAP_HOME}/golang/root
export GOPATH=${THWAP_HOME}/golang/path

add2path ${GOROOT}/bin
add2path ${GOPATH}/bin

for pkg in golang.org/x/tools/cmd/... \
           github.com/rogpeppe/godef/... \
           github.com/nsf/gocode \
           golang.org/x/tools/cmd/goimports \
           golang.org/x/tools/cmd/guru \
           github.com/dougm/goflymake; do
    go get -u ${pkg}
done


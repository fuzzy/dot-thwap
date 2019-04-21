case "$(uname -s)" in
    (Linux)
        NCPUS=$(grep rocessor /proc/cpuinfo|wc -l)
        GOROOT_BOOTSTRAP=/usr/lib/go
        TMAKE=$(which make)
        TTAR=$(which tar)
        TSED=$(which sed)
        ;;
    (FreeBSD)
        NCPUS=$(sysctl hw.ncpu|awk '{print $2}')
        GOROOT_BOOTSTRAP=/usr/local/go
        TMAKE=$(which gmake)
        TTAR=$(which gtar)
        TSED=$(which gsed)
        ;;
    (OpenBSD)
        NCPUS=$(sysctl hw.ncpu|awk '{print $2}')
        GOROOT_BOOTSTRAP=/usr/local/go
        TMAKE=$(which gmake)
        TTAR=$(which gtar)
        TSED=$(which gsed)
        ;;
esac

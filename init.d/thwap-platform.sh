case "$(uname -s)" in
    (Linux)
        NCPUS=$(grep rocessor /proc/cpuinfo|wc -l)
        GOROOT_BOOTSTRAP=/usr/lib/go
        TMAKE=$(which make)
    ;;
    (FreeBSD)
        NCPUS=$(sysctl hw.ncpu|awk '{print $2}')
        GOROOT_BOOTSTRAP=/usr/local/go
        TMAKE=$(which gmake)
    ;;
    (OpenBSD)
        NCPUS=$(sysctl hw.ncpu|awk '{print $2}')
        GOROOT_BOOTSTRAP=/usr/local/go
        TMAKE=$(which gmake)
    ;;
esac

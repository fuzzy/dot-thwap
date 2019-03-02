
tball=$(wget -q -O- http://ftp.gnu.org/gnu/emacs/|grep -E 'emacs-[0-9]+\.[0-9]+.*tar.xz'|awk -F'href="' '{print $2}'|awk -F'">' '{print $1}'|grep -v sig|sort -Vr|head -n1)
vers=$(echo ${tball}|awk -F- '{print $2}'|awk -F'.ta' '{print $1}')
url="http://ftp.gnu.org/gnu/emacs/${tball}"

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

if test ! -x ${THWAP_HOME}/emacs-${vers}/bin/emacs-${vers}; then
    cd ${THWAP_TEMP} ; rm -rf emacs-${vers}
    test ! -f ${tball} && wget ${url}
    tar -Jxf ${tball}
    cd emacs-${vers}
    ./configure --prefix=${THWAP_HOME}/emacs-${vers} --with-modules --with-x-toolkit=gtk2 --with-threads
    ${tmake} -j$(grep rocess ${PROC_CPU} | wc -l)
    ${tmake} install && cd ../ && rm -rf emacs-${vers}*
    cd
fi


add2path ${THWAP_HOME}/emacs-${vers}/bin

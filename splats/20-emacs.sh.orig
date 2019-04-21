
tball=$(wget -q -O- http://ftp.gnu.org/gnu/emacs/|grep -E 'emacs-[0-9]+\.[0-9]+.*tar.xz'|awk -F'href="' '{print $2}'|awk -F'">' '{print $1}'|grep -v sig|sort -Vr|head -n1)
vers=$(echo ${tball}|awk -F- '{print $2}'|awk -F'.ta' '{print $1}')
url="http://ftp.gnu.org/gnu/emacs/${tball}"

if test ! -x ${THWAP_HOME}/emacs-${vers}/bin/emacs-${vers}; then
    tout "\033[32m>>>\033[0m PKG: \033[36mEmacs ${vers}\033[0m\n"
    cd ${THWAP_TEMP} ; rm -rf emacs-${vers}
    test ! -f ${tball} && thwap_exec "Fetching" "wget -qc ${url}"
    thwap_exec "Extracting" "tar -Jxf ${tball}"
    cd emacs-${vers}
    thwap_exec "Configuring" "./configure --prefix=${THWAP_HOME}/emacs-${vers} --with-modules --with-x-toolkit=lucid --with-threads"
    thwap_exec "Compiling" "${TMAKE} -j${NCPUS}"
    thwap_exec "Installing" "${TMAKE} install" && cd ../ && rm -rf emacs-${vers}*
    cd
fi


add2path ${THWAP_HOME}/emacs-${vers}/bin

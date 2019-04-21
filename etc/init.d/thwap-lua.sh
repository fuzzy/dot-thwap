
vers=5.3.5
#vers=5.2.4
tball=lua-${vers}.tar.gz
url=http://www.lua.org/ftp/${tball}

lrvers=3.0.4
lrtball=luarocks-${lrvers}.tar.gz
lrurl=https://luarocks.org/releases/${lrtball}

case "$(uname -s)" in
    (Linux)   platform=linux ;;
    (FreeBSD) platform=freebsd ;;
    (*)       platform=posix ;;
esac

INST_ROOT=${THWAP_HOME}/lua/${vers}

if test ! -x ${INST_ROOT}/bin/luac; then
    tout "\033[32m>>>\033[0m PKG: \033[36mLua ${vers}\033[0m\n"
    cd ${THWAP_TEMP} ; thwap_exec "Fetching" "$(which wget) -qc ${url}"
    thwap_exec "Extracting" "tar -zxf ${tball}"
    cd ${THWAP_TEMP}/lua-${vers}
    printf "s,^#define.*LUA_ROOT.*\"/usr/local/\",#define LUA_ROOT \"${INST_ROOT}/\",g" >.pattern
    sed -i -E "$(cat .pattern)" src/luaconf.h
    thwap_exec "Compiling" "make -j${NCPUS} ${platform} INSTALL_TOP=${THWAP_HOME}/lua/${vers}"
    thwap_exec "Installing" "make install INSTALL_TOP=${THWAP_HOME}/lua/${vers}"
    cd .. ; rm -rf ${THWAP_TEMP}/lua-${vers}* ; cd
fi

# The next step needs this, so moving it up here fixes that, and it's the same
# directory as luarocks anyway, so no functionality got changed
add2path ${THWAP_HOME}/lua/${vers}/bin

if test ! -x ${THWAP_HOME}/lua/${vers}/bin/luarocks; then
    tout "\033[32m>>>\033[0m PKG: \033[36mLuaRocks ${lrvers}\033[0m\n"
    cd ${THWAP_TEMP} ; thwap_exec "Fetching" "$(which wget) -qc ${lrurl}"
    thwap_exec "Extracting" "tar -zxf ${lrtball}"
    cd ${THWAP_TEMP}/luarocks-${lrvers}
    thwap_exec "Configuring" "./configure --prefix=${THWAP_HOME}/lua/${vers}"
    thwap_exec "Compiling" "make"
    thwap_exec "Installing" "make install"
    cd .. ; rm -rf ${THWAP_TEMP}/luarocks-${lrvers}* ; cd
    case "${THWAP_OS}" in
        (FreeBSD)
            LUAROCKS_CFG=${THWAP_HOME}/lua/${vers}/etc/luarocks/config-$(echo ${vers}|cut -b 1,2,3).lua
            ${TSED} -i $'s,variables = {,&\\\nUNZIP = "/usr/local/bin/unzip";,g' ${LUAROCKS_CFG}
            ;;
    esac
    for rock in luaposix luafilesystem; do
        thwap_exec "LuaRock: ${rock}" "luarocks install ${rock}"
    done
    short_v=$(echo ${vers}|cut -b 1,2,3)
    cmd="ln -sf ${THWAP_SHARE}/thwap ${THWAP_HOME}/lua/${vers}/share/lua/${short_v}/thwap"
    thwap_exec "LuaRock: thwap" "${cmd}"
fi



rockspec_format = "1.1"
package = "luathwap-0.0.1"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   summary = "T.H.W.A.P. Lua Utilities",
   homepage = "https://git.devfu.net/fuzzy/luathwap",
   license = "BSD 2-Clause"
}
dependencies = {
   "lua >= 5.2, < 5.4",
   "luaposix"
}
build = {
   type = "builtin",
   modules = {}
}

------------------------
-- Dynamic configuration module. There are no methods, no functions.
-- The config object that is returned is a table with all of the
-- configuration directives inside it. It reads in configration files
-- in the following order:
--
-- <ol><li>~/.thwap/init.d/thwap.config</li>
-- <li>~/.thwaprc</li>
-- <li>/etc/thwap/thwap.config</li></ol>
--
-- Stopping at the first result found. It then goes on to do system
-- dependent configuration. In this case we standardize on GNU utilities
-- so we specify the g* variants on the *BSD systems.
--
-- 04/05/2019 - Mike 'Fuzzy' Partin <fuzzy@thwap.org>
-- <li>Initial modularization</li>
-- <li>Documented the configuration fields a bit</li>
--
-- @module config

-- external deps
local utsname       = require "posix.sys.utsname"

-- internal deps
local utils         = require "thwap.utils"
local output        = require "thwap.output"


-- define the base config object
local config        = {
   -- Operating System Name (string)
   osname           = utsname.uname().sysname,
   -- Machine Architecture (string)
   arch             = utsname.uname().machine,
   -- Number of available CPU cores (string)
   cpus             = "1",
   -- Tools (table)
   tools            = {
      -- Make utility (GNU Make) (string)
      make          = "make",
      -- Sed utility (GNU Sed) (string)
      sed           = "sed",
      -- Awk utility (GNU Awk) (string)
      awk           = "awk",
   },
   -- Directories (table)
   dirs             = {}
}

-- define the platform dependent stuff
local tos           = config.osname:lower()
if tos == "linux" then
   config.cpus      = io.popen("grep rocessor /proc/cpuinfo|wc -l"):read()
elseif tos:find("bsd") then
   config.tools     = {
      make          = utils.which("gmake"),
      sed           = utils.which("gsed"),
      awk           = utils.which("gawk")
   }
   config.cpus      = io.popen("sysctl hw.ncpu|awk '{print $2}'"):read()
end

-- Base directory (string)
config.dirs.base    = string.format("%s/.thwap",  os.getenv("HOME"))
-- Configuration directory (string)
config.dirs.config  = string.format("%s/etc",     config.dirs.base)
-- Init directory (string)
config.dirs.init    = string.format("%s/init.d",  config.dirs.config)
-- Library directory (string)
config.dirs.library = string.format("%s/usr",     config.dirs.base)
-- Package definition directory (string)
config.dirs.package = string.format("%s/splats",  config.dirs.base)
-- "Home" directory (install prefix) (string)
config.dirs.home    = string.format("%s/%s/%s",   config.dirs.library, config.osname, config.arch)
-- Temp directory (string)
config.dirs.temp    = string.format("%s/temp",    config.dirs.base)

-- now let's find our config file, and load it in
local configs       = {
   string.format("%s/.thwaprc", os.getenv("HOME")),
   string.format("%s/.thwap/etc/thwap.config", os.getenv("HOME")),
   "/etc/thwap.config"   
}

local tdata = {}
for i, v in pairs(configs) do
   if utils.isFile(v) then
      tdata  = dofile(v)
      break
   end
end   

for k, v in pairs(tdata) do
   config.dirs[k] = v
end

-- finally, we can hand back the config object
return config

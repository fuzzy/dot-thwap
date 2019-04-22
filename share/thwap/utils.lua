------------------------
-- Utility functions
--
-- 04/05/2019 - Mike 'Fuzzy' Partin <fuzzy@thwap.org>
-- <ol><li>Initial modularization</li></ol>
--
-- TODO
-- This needs to log the command, and all the output
-- to disk, and display a message to the user stating
-- where to find said file.

-- @module utils

local utils   = {}

-- 3rd party
local stdlib  = require "posix.stdlib"
local stat    = require "posix.sys.stat"
local dirent  = require "posix.dirent"
local unistd  = require "posix.unistd"

-- local stuff
local output  = require "thwap.output"

--- <b>isDir(str) => bool</b><br />
-- Quick utility function to check if a directory exists.
-- @param str
-- String containing pathname + dirname
-- @return bool
function utils.isDir(str)
   local tmp  = stat.stat(str)
   if tmp and stat.S_ISDIR(tmp.st_mode) == 1 then
      return true
   else
      return false
   end
end

--- <b>isFile(str) => bool</b><br />
-- Quick utility function to check if a file exists.
-- @param str
-- String containing pathname + filename
-- @return bool
function utils.isFile(str)
   local tmp  = stat.stat(str)
   if tmp and stat.S_ISREG(tmp.st_mode) == 1 then
      return true
   else
      return false
   end
end

--- <b>isLink(str) => bool</b><br />
-- Quick utility function to check if a link exists.
-- @param str
-- String containing pathname + linkname
-- @return bool
function utils.isLink(str)
   local tmp  = stat.lstat(str)
   if tmp and stat.S_ISLNK(tmp.st_mode) == 1 then
      return true
   else
      return false
   end
end

--- <b>linkTgt(str) => str</b><br />
-- Quick utility function return the target of the link.
-- @param str
-- String containing pathname + target
-- @return str
function utils.linkTgt(str)
   if utils.isLink(str) then
      return stdlib.realpath(str)
   end
   return nil
end

--- <b>mkDir(str)</b><br />
-- Utility function to create a directory (like mkdir [dir])
-- @param str
-- String containing pathname + dirname
function utils.mkDir(str)
   output.info(string.format("Creating: %s", str))
   stat.mkdir(str)
end

--- <b>mkDirs(str)</b><br />
-- Utility function to create a directory tree (like mkdir -p [dir])
-- @param str
-- String containing pathname + dirname
function utils.mkDirs(str)
   local tdir = "/"
   for k, v in pairs(split(str, "/")) do
      tdir = string.format("%s%s/", tdir, v)
      if not utils.isDir(tdir) then
         utils.mkDir(tdir)
      end
   end
end

--- <b>which(str) => str</b><br />
-- Utility function that operates like the command 'which'
-- returns a string on success, or nil on failure.
-- @param str
-- String containing the filename to search for in $PATH
-- @return str
-- String containing the pathname + filename where found in the $PATH, or nil if not found.
function utils.which(str)
   for dk, dn in pairs(utils.split(os.getenv('PATH'), ':')) do
      if utils.isDir(dn) then
         for fk, fn in pairs(dirent.dir(dn)) do
            if fn == str then
               return string.format("%s/%s", dn, fn)
            end
         end
      end
   end
   return nil
end

--- <b>split(str, sep) => table</b><br />
-- Utility to split strings given a seperator (space by default).
-- @param str
-- String to be split
-- @param sep
-- String containing the seperator to split by ('%s' by default)
-- @return table
-- An array of elements as created by splitting str
function utils.split(str, sep)
   local sep, t = sep or '%s', {}
   for tstr in string.gmatch(str, string.format("[^%s]+", sep)) do
      table.insert(t, tstr)
   end
   return t
end

--- <b>run(cmd, msg, cwd) => table{"success": bool, "output": table}</b><br />
-- Utility to run a command and show status, as well as log output.
-- @param cmd
-- String containing the command to run
-- @param msg
-- String containing the status message to display
-- @param cwd
-- String containing the directory to execute the command from
-- @return table
-- Table with the keys {success = bool, output = {}}
function utils.run(cmd, msg, cwd)
   -- setup our variables
   local mesg  = msg or cmd
   local retv  = {}
   local sdir  = unistd.getcwd()

   -- setup our return variable, and show status if desired
   retv.output = {}
   output.status(mesg..": ")
   
   -- change running dir if needed
   if cwd then
      unistd.chdir(cwd)
   end

   -- execute the command
   file        = io.popen(cmd.." 2>&1")
   local buff  = file:read()
   while buff do
      if string.len(buff) > 0 then
         table.insert(retv.output, buff)
      end
      buff = file:read()
   end

   -- setup the return object
   retv.success, retv.action, retv.status  = file:close()
   if retv.success then
      output.success()
   else
      output.failure()
      local logft = "/tmp/thwap-error-XXXXXXXXXXXX"
      local logfp, logfn = stdlib.mkstemp(logft)
      logfp = io.open(logfn, "w+")
      for i, l in pairs(retv.output) do
         logfp:write(l.."\n")
      end
      logfp:close()
      output.err(logfn)
   end

   -- change working dirs back if we changed at all
   if cwd then
      unistd.chdir(sdir)
   end

   -- and hand everything back
   return retv
end

return utils



----------------------
-- An Object-Oriented build engine for THWAP
--
-- 04/05/2019 - Mike 'Fuzzy' Partin <fuzzy@thwap.org>
-- <li>Initial OOPization of the older proof of concept procedural code</li>
-- <li>Other thing I did</li>
--
-- @module builder

-- The Builder class.
-- @type Builder
local Builder = {
   config     = nil,
   package    = nil
}

local utils        = require "thwap.utils"
local output       = require "thwap.output"
local libgen       = require "posix.libgen"
local unistd       = require "posix.unistd"

--- <b>Builder:new(cfg)</b><br />
-- Pass in a configuration and a pacakge object, get yourself a Builder
-- object, in return.
-- @param cfg The configuration object.
-- @return Builder
function Builder:new(cfg)
   obj             = {}
   setmetatable(obj, self)
   self.__index    = self
   obj.config      = cfg
   return obj
end

--- <b>Builder:open(pkg) => bool</b><br />
-- Open a given package definition to build.
-- @param pkg
-- String describing the package definition filename (not pathname)
-- @return bool
function Builder:open(pkg)
   local pkg_fn    = ""
   if string.find(pkg, ".pkg") then
      pkg_fn       = self.config.dirs.package.."/"..pkg
   else
      pkg_fn       = self.config.dirs.package.."/"..pkg..".pkg"
   end
   if utils.isFile(pkg_fn) then
      self.package = dofile(pkg_fn)
      -- configure defaults
      if not self.package.configure then
         self.package.configure = {command = "./configure"}
      end
      if not self.package.configure.command then
         self.package.configure.command = "./configure"
      end
      -- compile defaults
      if not self.package.compile then
         self.package.compile   = {command = self.config.tools.make}
      end
      if not self.package.compile.command then
         self.package.compile.command = self.config.tools.make
      end
      -- install defaults
      if not self.package.install then
         self.package.install   = {command = self.config.tools.make,
                                   arguments = "install"}
      end
      if not self.package.install.command then
         self.package.install.command = self.config.tools.make
      end
      if not self.package.versions then
         output.fatal('No defined versions found.')
      elseif #self.package.versions > 1 then
         if not self.package.default then
            output.fatal('No default version specified.')
         end
      elseif #self.package.versions == 1 then
         if not self.package.default then
            for k,v in pairs(self.package.versions) do
               self.package.default = v.name
            end
         end
      end
      return true
   end
   return false
end

--- <b>Builder:build(vers) => bool</b><br />
-- Build a specific version
-- @param vers
-- String matching the 'name' parameter of a version entry
-- @return bool
function Builder:build(vers)
   for k, v in pairs(self.package.versions) do
      if vers == v.name and v.provides then
         local bdir = string.format("%s/%s/%s/%s",
                                    self.config.dirs.home,
                                    string.lower(self.package.name),
                                    v.name, v.provides)
         -- dbug(flag)
         if not utils.isFile(bdir) then
            self.package._current = v.name
            output.status("Pkg: ")
            io.stderr:write(string.format("%s-%s\n", self.package.name, v.name))
            -- fetch
            self:doFetch()
            -- extract
            self:doExtract()
            -- patch
            self:doPatch()
            -- configure
            self:doConfigure()
            -- compile
            self:doCompile()
            -- install
            self:doInstall()
         end
         -- check defaults
         self:doDefault()
         -- finally print the bindir for shell integration
         local pdir = string.format("%s/%s/default/bin",
                                    self.config.dirs.home,
                                    string.lower(self.package.name),
                                    v.name)
         if utils.isDir(pdir) then
            print(pdir)
         end
      end
   end
end

--- <b>Builder:version(vers) => table</b><br />
-- This returns a given version as referenced by the name field.
-- Returns nil on failure
-- @param vers
-- String describing a versions 'name' field
-- @return table/nil
function Builder:version(vers)
   for k, v in pairs(self.package.versions) do
      if v.name == vers then
         return v
      end
   end
   return nil
end

--- <b>Builder:doFetch() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doDefault()
   local mldir = string.format("%s/%s/default",
                              self.config.dirs.home,
                              string.lower(self.package.name))
   local mtdir = string.format("%s/%s/%s",
                              self.config.dirs.home,
                              string.lower(self.package.name),
                              self.package.default)
   if not utils.isLink(mldir) then
      unistd.link(mtdir, mldir, true)
   else
      if utils.linkTgt(mldir) ~= mtdir then
         -- remove the default link
         unistd.unlink(mldir)
         -- create the default link
         unistd.link(mtdir, mldir, true)
      end
   end
end

--- <b>Builder:doFetch() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doFetch()
   local vers = self:version(self.package._current)
   if vers then
      return utils.run("wget -cq "..vers.url,
                       "Fetching", self.config.dirs.temp)
   end
end

--- <b>Builder:doExtract() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doExtract()
   local vrs = self:version(self.package._current)
   if vrs then
      local fn = libgen.basename(vrs.url)
      local pn = self.config.dirs.temp
      if utils.isFile(string.format("%s/%s", pn, fn)) then
         utils.run("tar -xf "..fn, "Extracting", pn)
      end
   end
   if not vrs.source_dir then
      self.package._source_dir = string.format("%s/%s-%s",
                                               self.config.dirs.temp,
                                               self.package.name,
                                               vrs.name)
   else
      self.package._source_dir = string.format("%s/%s",
                                               self.config.dirs.temp,
                                               vrs.source_dir)
   end
end

--- <b>Builder:doPatch() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doPatch()
end

--- <b>Builder:doConfigure() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doConfigure()
   local v = self:version(self.package._current)
   local arguments = string.format("--prefix=%s/%s/%s",
                                   self.config.dirs.home,
                                   self.package.name:lower(),
                                   v.name)
   local command = nil
   if v.configure and v.configure.command then
      command = v.configure.command
   else
      command = self.package.configure.command
   end
   
   if v.configure and v.configure.arguments then
      arguments = arguments.." "..v.configure.arguments
   end
   
   if self.package.configure and self.package.configure.arguments then
      arguments = arguments.." "..self.package.configure.arguments
   end
   local cmd = string.format("./%s %s", command, arguments)
   utils.run(cmd, "Configuring", self.package._source_dir)
end

--- <b>Builder:doCompile() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doCompile()
   local cmd = nil
   local arg = nil
   local pkg = self:version(self.package._current)
   if self.package.compile then
      if self.package.compile.command then
         cmd = self.package.compile.command
      end
      if self.package.compile.arguments then
         arg = string.format("-j%s %s",
                             self.config.cpus,
                             self.package.compile.args)
      else
         arg = string.format("-j%s", self.config.cpus)
      end
   end
   -- per package overrides
   if pkg.compile then
      if pkg.compile.command then
         cmd = pkg.compile.command
      end
      if pkg.compile.arguments then
         args = string.format("%s %s", arg, pkg.compile.arguments)
      end
   end
   local cmds = string.format("%s %s", cmd, arg)
   utils.run(cmds, "Compiling", self.package._source_dir)
end

--- <b>Builder:doInstall() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doInstall()
   local cmd = nil
   local arg = nil
   local pkg = self:version(self.package._current)
   if self.package.install then
      if self.package.install.command then
         cmd = self.package.install.command
      end
      if self.package.install.arguments then
         arg = self.package.install.arguments
      end
   end
   -- per package overrides
   if pkg.install then
      if pkg.install.command then
         cmd = pkg.install.command
      end
      if pkg.install.arguments then
         args = string.format("%s %s", arg, pkg.install.arguments)
         arg = args
      end      
   end
   local cmds = string.format("%s %s", cmd, arg)
   utils.run(cmds, "Installing", self.package._source_dir)
end

--- <b>Builder:doCleanup() => bool</b><br />
-- This operates on the property: self.package._current which should be
-- directly relatable to a version entrys name attribute.
-- @return bool
function Builder:doCleanup()
end

-- and hand off the object
return Builder


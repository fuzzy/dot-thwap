local backup = {}
local output = require "thwap.output"

--- <b>backup:new(cfg)</b><br />
-- Pass in a configuration and a pacakge object, get yourself a Builder
-- object, in return.
-- @param cfg The configuration object.
-- @return backup object
function backup:new(cfg)
   obj             = {}
   setmetatable(obj, self)
   self.__index    = self
   obj.config      = cfg
   return obj
end

function backup:backup()
   output.err("You forgot to override the backup method.")
end

function backup:cleanup()
   output.err("You forgot to override the cleanup method.")
end

return backup

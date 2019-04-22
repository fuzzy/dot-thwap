------------------------
-- Output functions and string type methods
--
-- 04/05/2019 - Mike 'Fuzzy' Partin <fuzzy@thwap.org>
-- <li>Initial modularization</li>
--
-- TODO:
-- Detect if the running shell is interactive or not and
-- use that to determine if output is desired.
--
-- TODO:
-- syslog style log level settings.
--
-- @module output

-- return object
local output = {}


local escStr = string.char(27) .. '[%dm'
local function esc(number)
  return escStr:format(number)
end

local function _msg(b, c, h, str)
   return string.format("%s%s%s%s %s%s%s", esc(b),  esc(c), h,
                        esc(0),            esc(37), str,    esc(0))
end

--- <b>string:red() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:red()
   return string.format("%s%s%s", esc(31), self, esc(0))
end

--- <b>string:green() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:green()
   return string.format("%s%s%s", esc(32), self, esc(0))
end

--- <b>string:yellow() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:yellow()
   return string.format("%s%s%s", esc(33), self, esc(0))
end

--- <b>string:blue() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:blue()
   return string.format("%s%s%s", esc(34), self, esc(0))
end

--- <b>string:purple() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:purple()
   return string.format("%s%s%s", esc(35), self, esc(0))
end

--- <b>string:cyan() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:cyan()
   return string.format("%s%s%s", esc(36), self, esc(0))
end

--- <b>string:white() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:white()
   return string.format("%s%s%s", esc(37), self, esc(0))
end

--- <b>string:black() => string</b><br />
-- String method to colorize the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:black()
   return string.format("%s%s%s", esc(30), self, esc(0))
end

--- <b>string:bold() => string</b><br />
-- String method to emBOLDen the text.
-- @param self
-- String type
-- @return string
-- String (self) wrapped in ANSI escape sequences.
function string:bold()
   return string.format("%s%s", esc(1), self)
end

--- <b>status(str)</b><br />
-- Show (str) without a newline, suitable for status prompts
-- @param str
-- String containing the text to display
function output.status(str)
   -- _msg(0, 32, ">>>", str))
   local prompt = ">>>"
   io.stderr:write(string.format("%s %s", prompt:bold():green(), str))
end

--- <b>success()</b><br />
-- Show a bold green 'OK'
function output.success()
   io.stderr:write(string.format("%s%sOK%s\n", esc(1), esc(32), esc(0)))
end

--- <b>failure()</b><br />
-- Show a bold red 'ERR'
function output.failure()
   io.stderr:write(string.format("%s%sERR%s\n", esc(1), esc(31), esc(0)))
end

--- <b>info(str)</b><br />
-- Show (str) prefixed by a triplet of green '>'
-- @param str
-- String containing the text to display
function output.info(str)
   io.stderr:write(_msg(0, 32, ">>>", str.."\n"))
end

--- <b>dbug(str)</b><br />
-- Show (str) prefixed by a triplet of purple '>'
-- @param str
-- String containing the text to display
function output.dbug(str)
   io.stderr:write(_msg(1, 35, ">>>", str.."\n"))
end

--- <b>warn(str)</b><br />
-- Show (str) prefixed by a triplet of yellow '>'
-- @param str
-- String containing the text to display
function output.warn(str)
   io.stderr:write(_msg(0, 33, ">>>", str.."\n"))
end

--- <b>err(str)</b><br />
-- Show (str) prefixed by a triplet of red '>'
-- @param str
-- String containing the text to display
function output.err(str)
   io.stderr:write(_msg(0, 31, ">>>", str.."\n"))
end

--- <b>fatal(str)</b><br />
-- Show (str) prefixed by a triplet of bold red '>'
-- followed by a program exit.
-- @param str
-- String containing the text to display
function output.fatal(str)
   io.stderr:write(_msg(1, 31, "!!!", str.."\n"))
   os.exit(1)
end

return output

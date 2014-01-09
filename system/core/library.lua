-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local debug = ProbablyEngine.debug

local library = {}
ProbablyEngine.library = library

library.libs = {}
function library.register(name, lib)
  if library.libs[name] then
    debug.print('Cannot overwrite library:' .. name, 'library')
    return false
  end

  library.libs[name] = lib
end

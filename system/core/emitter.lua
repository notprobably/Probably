-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local debug = ProbablyEngine.debug

ProbablyEngine.emitter = {}
local emitter = ProbablyEngine.emitter

local events = {}

function emitter.on(event, callback)
  debug.print('Event Registered: ' .. event, 'event')

  if not events[event] then
    events[event] = {}
  end

  table.insert(events[event], { callback = callback })
end

function emitter.once(event, callback)
  debug.print('One Time Event Registered: ' .. event, 'event')

  if not events[event] then
    events[event] = {}
  end

  table.insert(events[event], { callback = callback, once = true })
end

function emitter.remove(event, callback)
  for i = 1, #events[event] do
    if events[event][i].callback == callback then
      debug.print('Event Unregistered: ' .. event, 'event')
      table.remove(events[event], i)
    end
  end

  if #events[event] == 0 then
    events[event] = nil
  end
end

function emitter.emit(name, ...)
  if not events[name] then
    return false
  end

  for i = 1, #events[name] do
    debug.print('Event Called: ' .. name, 'event')
    events[name][i].callback(...)
    if events[name][i].once then
      emitter.remove(name, events[name][i].callback)
    end
  end

  return true
end

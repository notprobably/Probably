-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local GetCurrentKeyBoardFocus = GetCurrentKeyBoardFocus
local IsShiftKeyDown = IsShiftKeyDown

local register = ProbablyEngine.dsl.dsl.rules.register

local modifier = {}
function modifier.shift()
  return IsShiftKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.control()
  return IsControlKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.alt()
  return IsAltKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.lshift()
  return IsLeftShiftKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.lcontrol()
  return IsLeftControlKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.lalt()
  return IsLeftAltKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.rshift()
  return IsRightShiftKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.rcontrol()
  return IsRightControlKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

function modifier.ralt()
  return IsRightAltKeyDown() == 1 and GetCurrentKeyBoardFocus() == nil
end

register('modifier', modifier)

-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local units = { 'player', 'pet', 'vehicle', 'target', 'focus', 'mouseover', 'none', 'npc', 'party', 'raid', 'boss', 'arena' }

local register = ProbablyEngine.dsl.rules.register

register('condition', 'health', function (unit)
  return math.floor(UnitHealth(unit) / UnitHealthMax(unit) * 100)
end)

function unit.alive()
  UnitIsDeadOrGhost
end

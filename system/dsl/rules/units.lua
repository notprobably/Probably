-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local register = ProbablyEngine.dsl.rules.register

register('unit', 'tank', function ()
  local tank = 'player'
  local highestUnit

  -- I really want to mess with the raid module :/
  -- Raid Module SHOULD WORK WITHOUT BEING IN A RAID / PARTY
  -- Raid Module should also keep track of roles
  local lowest, highest = 1, 0
  for unit in pairs(ProbablyEngine.raid.roster) do
    local health = UnitHealth(unit) / UnitHealthMax(unit)
    if UnitGroupRolesAssigned(unit) == 'TANK' then
      if health < lowest then
        lowest = health
        tank = unit
      end
    else
      if health > highest then
        highest = health
        highestUnit = unit
      end
    end
  end

  if GetNumGroupMembers() > 0 and tank == 'player' then
    tank = highestUnit
  end

  return tank
end)

register('unit', 'method_missing', function (unit)
  if type(unit) ~= 'string' then
    error('Rule Unit expects a string, recieved a ' .. type(unit))
  end

  if UnitExists(unit) then
    return unit
  end
end)

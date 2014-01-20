-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local GetShapeshiftForm = GetShapeshiftForm

local player = ProbablyEngine.dsl.get('rules').get('unit').get('player')

function player.stance()
  return GetShapeshiftForm()
end

player.form = player.stance
player.seal = player.stance

function player.infront()
  return ProbablyEngine.module.player.infront
end

function player.behind()
  return ProbablyEngine.module.player.behind
end

function player.swimming()
  return IsSwimming()
end

function player:timetomax()
  local current, max = UnitPower(self.unitID), UnitPowerMax(self.unitID)
  local regen = select(2, GetPowerRegen(self.unitID))
  return (max - current) * (1.0 / regen)
end

player.tomax = player.timetomax

function player:falling()
  return IsFalling()
end

function player:time()
  return GetTime() - ProbablyEngine.module.player.combatTime
end

function player:mushrooms()
  local count = 0
  for slot = 1, 3 do
    if GetTotemInfo(slot) then count = count + 1 end
  end
  return count
end

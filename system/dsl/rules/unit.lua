-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local register = ProbablyEngine.dsl.get('rules').register

local prefixes = {
  '^player',
  '^pet',
  '^vehicle',
  '^target',
  '^focus',
  '^mouseover',
  '^none',
  '^npc',
  '^party[1-4]',
  '^raid[1-4]?[0-9]',
  '^boss[1-5]',
  '^arena[1-5]'
}

local function validate(unitID)
  local length, offset = string.len(unitID), 0
  for i = 1, #prefixes do
    local start, index = string.find(unitID, prefixes[i])
    if start then
      offset = index + 1
      if offset > length then
        return true
      else
        while true do
          local start, index = string.find(unitID, 'target', offset, true)
          if start then
            offset = index + 1
            if offset > length then
              return true
            end
          else
            return false
          end
        end
      end
    end
  end

  return false
end

local unit, cache = {}, {}
local function get(unitID)
  if cache[unitID] then
    return cache[unitID]
  end

  cache[unitID] = setmetatable({ unitID = unitID }, { __index = unit })
  return cache[unitID]
end

register('unit', {
  get = get,
  validate = validate,
  unit = unit
})


-- local register = ProbablyEngine.dsl.rules.register

-- register('unit', 'tank', function ()
--   local tank = 'player'
--   local highestUnit

--   -- I really want to mess with the raid module :/
--   -- Raid Module SHOULD WORK WITHOUT BEING IN A RAID / PARTY
--   -- Raid Module should also keep track of roles
--   local lowest, highest = 1, 0
--   for unit in pairs(ProbablyEngine.raid.roster) do
--     local health = UnitHealth(unit) / UnitHealthMax(unit)
--     if UnitGroupRolesAssigned(unit) == 'TANK' then
--       if health < lowest then
--         lowest = health
--         tank = unit
--       end
--     else
--       if health > highest then
--         highest = health
--         highestUnit = unit
--       end
--     end
--   end

--   if GetNumGroupMembers() > 0 and tank == 'player' then
--     tank = highestUnit
--   end

--   return tank
-- end)

-- register('unit', 'method_missing', function (unit)
--   if type(unit) ~= 'string' then
--     error('Rule Unit expects a string, recieved a ' .. type(unit))
--   end

--   if UnitExists(unit) then
--     return unit
--   end
-- end)

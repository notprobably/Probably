-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local rangeCheck = LibStub("LibRangeCheck-2.0")
local LibDispellable = LibStub("LibDispellable-1.0")
local LibBoss = LibStub("LibBoss-1.0")

ProbablyEngine.condition.register("toggle", function(toggle, spell)
  return ProbablyEngine.condition["modifier.toggle"](toggle)
end)

ProbablyEngine.condition.register("modifier.toggle", function(toggle)
  return ProbablyEngine.config.read('button_states', toggle, false)
end)

ProbablyEngine.condition.register("modifier.taunt", function()
  if ProbablyEngine.condition["modifier.toggle"]('taunt') then
    if UnitThreatSituation("player", "target") then
      local status = UnitThreatSituation("player", target)
      return (status < 3)
    end
    return false
  end
  return false
end)


ProbablyEngine.condition.register("balance.sun", function(target, spell)
  local direction = GetEclipseDirection()
  if direction == 'none' or direction == 'sun' then return true end
end)

ProbablyEngine.condition.register("balance.moon", function(target, spell)
  local direction = GetEclipseDirection()
  if direction == 'moon' then return true end
end)


-- DK Power

ProbablyEngine.condition.register("runicpower", function(target, spell)
  return UnitPower(target, SPELL_POWER_RUNIC_POWER)
end)

ProbablyEngine.condition.register("runes.count", function(target, rune)
  rune = string.lower(rune)
  if rune == 'frost' then
    local r1 = select(3, GetRuneCooldown(5))
    local r2 = select(3, GetRuneCooldown(6))
    local f1 = GetRuneType(5)
    local f2 = GetRuneType(6)
    if (r1 and f1 == 3) and (r2 and f2 == 3) then
      return 2
    elseif (r1 and f1 == 3) or (r2 and f2 == 3) then
      return 1
    else
      return 0
    end
  elseif rune == 'blood' then
    local r1 = select(3, GetRuneCooldown(1))
    local r2 = select(3, GetRuneCooldown(2))
    local b1 = GetRuneType(1)
    local b2 = GetRuneType(2)
    if (r1 and b1 == 1) and (r2 and b2 == 1) then
      return 2
    elseif (r1 and b1 == 1) or (r2 and b2 == 1) then
      return 1
    else
      return 0
    end
  elseif rune == 'unholy' then
    local r1 = select(3, GetRuneCooldown(3))
    local r2 = select(3, GetRuneCooldown(4))
    local u1 = GetRuneType(3)
    local u2 = GetRuneType(4)
    if (r1 and u1 == 2) and (r2 and u2 == 2) then
      return 2
    elseif (r1 and u1 == 2) or (r2 and u2 == 2) then
      return 1
    else
      return 0
    end
  elseif rune == 'death' then
    local r1 = select(3, GetRuneCooldown(1))
    local r2 = select(3, GetRuneCooldown(2))
    local r3 = select(3, GetRuneCooldown(3))
    local r4 = select(3, GetRuneCooldown(4))
    local d1 = GetRuneType(1)
    local d2 = GetRuneType(2)
    local d3 = GetRuneType(3)
    local d4 = GetRuneType(4)
    local total = 0
    if (r1 and d1 == 4) then
      total = total + 1
    end
    if (r2 and d2 == 4) then
      total = total + 1
    end
    if (r3 and d3 == 4) then
      total = total + 1
    end
    if (r4 and d4 == 4) then
      total = total + 1
    end
    return total
  end
  return 0
end)

ProbablyEngine.condition.register("runes.depleted", function(target, spell)
    local regeneration_threshold = 1
    for i=1,6,2 do
        local start, duration, runeReady = GetRuneCooldown(i)
        local start2, duration2, runeReady2 = GetRuneCooldown(i+1)
        if not runeReady and not runeReady2 and duration > 0 and duration2 > 0 and start > 0 and start2 > 0 then
            if (start-GetTime()+duration)>=regeneration_threshold and (start2-GetTime()+duration2)>=regeneration_threshold then
                return true
            end
        end
    end
    return false
end)

ProbablyEngine.condition.register("runes", function(target, rune)
  return ProbablyEngine.condition["runes.count"](target, rune)
end)

ProbablyEngine.condition.register("health", function(target, spell)
  if UnitExists(target) then
    return math.floor((UnitHealth(target) / UnitHealthMax(target)) * 100)
  end
  return 0
end)

ProbablyEngine.condition.register("raid.health", function()
  return ProbablyEngine.raid.raidPercent()
end)

ProbablyEngine.condition.register("modifier.multitarget", function()
  return ProbablyEngine.condition["modifier.toggle"]('multitarget')
end)

ProbablyEngine.condition.register("modifier.cooldowns", function()
  return ProbablyEngine.condition["modifier.toggle"]('cooldowns')
end)

ProbablyEngine.condition.register("modifier.cooldown", function()
  return ProbablyEngine.condition["modifier.toggle"]('cooldowns')
end)

ProbablyEngine.condition.register("modifier.interrupts", function()
  if ProbablyEngine.condition["modifier.toggle"]('interrupt') then
    local stop = ProbablyEngine.condition["casting"]('target')
    if stop then SpellStopCasting() end
    return stop
  end
  return false
end)

ProbablyEngine.condition.register("modifier.interrupt", function()
  if ProbablyEngine.condition["modifier.toggle"]('interrupt') then
    return ProbablyEngine.condition["casting"]('target')
  end
  return false
end)

ProbablyEngine.condition.register("modifier.last", function(target, spell)
  return ProbablyEngine.parser.lastCast == GetSpellName(spell)
end)

ProbablyEngine.condition.register("modifier.enemies", function()
  local count = 0
  for _ in pairs(ProbablyEngine.module.combatTracker.enemy) do count = count + 1 end
  return count
end)

ProbablyEngine.condition.register("enchant.mainhand", function()
  return (select(1, GetWeaponEnchantInfo()) == 1)
end)

ProbablyEngine.condition.register("enchant.offhand", function()
  return (select(4, GetWeaponEnchantInfo()) == 1)
end)

ProbablyEngine.condition.register("totem", function(target, totem)
  for index = 1, 4 do
    local _, totemName, startTime, duration = GetTotemInfo(index)
    if totemName == GetSpellName(totem) then
      return true
    end
  end
  return false
end)

ProbablyEngine.condition.register("totem.duration", function(target, totem)
  for index = 1, 4 do
    local _, totemName, startTime, duration = GetTotemInfo(index)
    if totemName == GetSpellName(totem) then
      return floor(startTime + duration - GetTime())
    end
  end
  return 0
end)

ProbablyEngine.condition.register("mushrooms", function ()
  local count = 0
  for slot = 1, 3 do
    if GetTotemInfo(slot) then count = count + 1 end
  end
  return count
end)

local function checkChanneling(target)
  local name_, _, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo(target)
  if name then return name, startTime, endTime, notInterruptible end

  return false
end

local function checkCasting(target)
  local name, startTime, endTime, notInterruptible = checkChanneling(target)
  if name then return name, startTime, endTime, notInterruptible end

  local name, _, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(target)
  if name then return name, startTime, endTime, notInterruptible end

  return false
end

ProbablyEngine.condition.register('casting.time', function(target, spell)
  local name, startTime, endTime = checkCasting(target)
  if name then return (endTime - startTime) / 1000 end
  return false
end)

ProbablyEngine.condition.register('casting.delta', function(target, spell)
  local name, startTime, endTime, notInterruptible = checkCasting(target)
  if name and not notInterruptible then
    local castLength = (endTime - startTime) / 1000
    local secondsLeft = endTime / 1000  - GetTime()
    return secondsLeft, castLength
  end
  return false
end)

ProbablyEngine.condition.register('channeling', function (target, spell)
  return checkChanneling(target)
end)

ProbablyEngine.condition.register("casting", function(target, spell)
  local castName,_,_,_,_,endTime,_,_,notInterruptibleCast = UnitCastingInfo(target)
  local channelName,_,_,_,_,endTime,_,notInterruptibleChannel = UnitChannelInfo(target)
  spell = GetSpellName(spell)
  if (castName == spell or channelName == spell) and not not spell then
    return true
  elseif notInterruptibleCast == false or notInterruptibleChannel == false then
    return true
  end
  return false
end)

ProbablyEngine.condition.register('interruptsAt', function (target, spell)
  if ProbablyEngine.condition['modifier.toggle']('interrupt') then
    if UnitName('player') == UnitName(target) then return false end
    local stopAt = tonumber(spell) or 95
    local secondsLeft, castLength = ProbablyEngine.condition['casting.delta'](target)
    if secondsLeft and 100 - (secondsLeft / castLength * 100) > stopAt then
      SpellStopCasting()
      return true
    end
  end
  return false
end)

ProbablyEngine.condition.register('interruptAt', function (target, spell)
  if ProbablyEngine.condition['modifier.toggle']('interrupt') then
    if UnitName('player') == UnitName(target) then return false end
    local stopAt = tonumber(spell) or 95
    local secondsLeft, castLength = ProbablyEngine.condition['casting.delta'](target)
    if secondsLeft and 100 - (secondsLeft / castLength * 100) > stopAt then
      return true
    end
  end
  return false
end)

ProbablyEngine.condition.register("spell.cooldown", function(target, spell)
  local start, duration, enabled = GetSpellCooldown(spell)
  if not start then return false end
  if start ~= 0 then
    return (start + duration - GetTime())
  end
  return 0
end)

ProbablyEngine.condition.register("spell.recharge", function(target, spell)
  local charges, maxCharges, start, duration = GetSpellCharges(spell)
  if not start then return false end
  if start ~= 0 then
    return (start + duration - GetTime())
  end
  return 0
end)

ProbablyEngine.condition.register("spell.usable", function(target, spell)
  return (IsUsableSpell(spell) ~= nil)
end)

ProbablyEngine.condition.register("spell.exists", function(target, spell)
  if GetSpellBookIndex(spell) then
    return true
  end
  return false
end)

ProbablyEngine.condition.register("spell.casted", function(target, spell)
  return ProbablyEngine.module.player.casted(GetSpellName(spell))
end)

ProbablyEngine.condition.register("spell.charges", function(target, spell)
  return select(1, GetSpellCharges(spell))
end)

ProbablyEngine.condition.register("spell.cd", function(target, spell)
  return ProbablyEngine.condition["spell.cooldown"](target, spell)
end)

ProbablyEngine.condition.register("spell.range", function(target, spell)
  local spellIndex, spellBook = GetSpellBookIndex(spell)
  if not spellIndex then return false end
  return spellIndex and IsSpellInRange(spellIndex, spellBook, target) == 1
end)

ProbablyEngine.condition.register("glyph", function(target, spell)
  local spellId = tonumber(spell)
  local glyphName, glyphId

  for i = 1, 6 do
    glyphId = select(4, GetGlyphSocketInfo(i))
    if glyphId then
      if spellId then
        if select(4, GetGlyphSocketInfo(i)) == spellId then
          return true
        end
      else
        glyphName = GetSpellName(glyphId)
        if glyphName:find(spell) then
          return true
        end
      end
    end
  end
  return false
end)

ProbablyEngine.condition.register("modifier.party", function()
  return IsInGroup()
end)

ProbablyEngine.condition.register("modifier.raid", function()
  return IsInRaid()
end)

ProbablyEngine.condition.register("modifier.members", function()
  return (GetNumGroupMembers() or 0)
end)

ProbablyEngine.condition.register("creatureType", function (target, expectedType)
  return UnitCreatureType(target) == expectedType
end)

ProbablyEngine.condition.register("class", function (target, expectedClass)
  local class, _, classID = UnitClass(target)

  if tonumber(expectedClass) then
    return tonumber(expectedClass) == classID
  else
    return expectedClass == class
  end
end)

ProbablyEngine.condition.register("falling", function()
  return IsFalling() == 1
end)

ProbablyEngine.condition.register("modifier.timeout", function(_, spell, time)
  if ProbablyEngine.timeout.check(spell) then
    return ProbablyEngine.timeout.check(spell)
  else
    ProbablyEngine.timeout.set(spell, function()
      print(spell .. 'finished')
    end, tonumber(time))
  end
  return true
end)

local heroismBuffs = { 32182, 90355, 80353, 2825 }
ProbablyEngine.condition.register("hashero", function(unit, spell)
  for i = 1, #heroismBuffs do
    if UnitBuff('player', GetSpellName(heroismBuffs[i]) then
      return true
    end
  end

  return false
end)

ProbablyEngine.condition.register("charmed", function(unit, _)
  return (UnitIsCharmed(unit) == true)
end)

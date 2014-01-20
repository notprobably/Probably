-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local LibDispellable = LibStub('LibDispellable-1.0')

local unit = ProbablyEngine.dsl.get('rules').get('unit').unit

function unit:health()
  return math.floor(UnitHealth(self.unitID) / UnitHealthMax(self.unitID) * 100)
end

function unit:alive()
  UnitIsDeadOrGhost(self.unitID)
end

local buff = {}
function buff:find()
  self.found = false
  self.count = 0
  self.expires = nil

  local i = 1
  while i <= 40 do
    local name, _, _, count, _, _, expires, caster = UnitBuff(self.unitID, i)
    if not name then
      break
    end
    if name == self.spell then
      if not self.any then
        if caster == 'player' or caster == 'pet' then
          self.found = true
          self.count = count
          self.expires = expires
          return
        end
      else
        self.found = true
        self.count = count
        self.expires = expires
        return
      end
    end
    i = i + 1
  end
end
function buff:duration()
  self:find()
  if self.expires then
    return self.expires - GetTime()
  else
    return 0
  end
end
function buff:count()
  self:find()
  return self.count
end
function buff:__call()
  self:find()
  return self.found
end
buff.__index = buff

local debuff = {}
function debuff:find()
  self.found = false
  self.count = 0
  self.expires = nil

  local i = 1
  while i <= 40 do
    local name, _, _, count, _, _, expires, caster = UnitDebuff(self.unitID, i)
    if not name then
      break
    end
    if name == self.spell then
      if not self.any then
        if caster == 'player' or caster == 'pet' then
          self.found = true
          self.count = count
          self.expires = expires
          return
        end
      else
        self.found = true
        self.count = count
        self.expires = expires
        return
      end
    end
    i = i + 1
  end
end
function debuff:duration()
  self:find()
  if self.expires then
    return self.expires - GetTime()
  else
    return 0
  end
end
function debuff:count()
  self:find()
  return self.count
end
function debuff:__call()
  self:find()
  return self.found
end
debuff.__index = debuff

function unit:buff(spell, any)
  local spellID = tonumber(spell)
  if spellID then
    spell = GetSpellName(spell)
  end

  return setmetatable({ spell = spell, any = any, unitID = self.unitID }, buff)
end

function unit:debuff(spell, any)
  local spellID = tonumber(spell)
  if spellID then
    spell = GetSpellName(spell)
  end

  return setmetatable({ spell = spell, any = any, unitID = self.unitID }, debuff)
end

function unit:dispellable(action)
  if action.spell then
    return LibDispellable:CanDispelWith(self.unitID, GetSpellID(action.spell))
  else
    return LibDispellable:CanDispelWith(self.unitID, GetSpellID(action))
  end
end

function unit:focus()
  return UnitPower(self.unitID, SPELL_POWER_FOCUS)
end

function unit:holypower()
  return UnitPower(self.unitID, SPELL_POWER_HOLY_POWER)
end

function unit:shadoworbs()
  return UnitPower(self.unitID, SPELL_POWER_SHADOW_ORBS)
end

function unit:energy()
  return UnitPower(self.unitID, SPELL_POWER_ENERGY)
end

function unit:rage()
  return UnitPower(self.unitID, SPELL_POWER_RAGE)
end

function unit:chi()
  return UnitPower(self.unitID, SPELL_POWER_CHI)
end

function unit:demonicfury()
  return UnitPower(self.unitID, SPELL_POWER_DEMONIC_FURY)
end

function unit:embers()
  return UnitPower(self.unitID, SPELL_POWER_BURNING_EMBERS, true)
end

function unit:soulshards()
  return UnitPower(self.unitID, SPELL_POWER_SOUL_SHARDS)
end

function unit:disarmable()
  return ProbablyEngine.module.disarm.check(self.unitID)
end

function unit:combopoints()
  return GetComboPoints('player', self.unitID)
end

function unit:alive()
  return UnitExists(self.unitID) and not UnitIsDeadOrGhost(self.unitID)
end

function unit:dead()
  return UnitExists(self.unitID) and UnitIsDeadOrGhost(self.unitID)
end

function unit:target(target)
  return UnitGUID(self.unitID .. 'target') == UnitGUID(target)
end

function unit:player()
  return UnitGUID('player') == UnitGUID(self.unitID)
end

function unit:isPlayer()
  return UnitIsPlayer(self.unitID)
end

function unit:exists()
  return UnitExists(self.unitID)
end

function unit:classification(expected)
  if not expected then return false end
  local classification = UnitClassification(self.unitID)
  if stringFind(expected, '[%s,]+') then
    for classificationExpected in stringGmatch(expected, '%a+') do
      if classification == stringLower(classificationExpected) then
        return true
      end
    end
    return false
  else
    return UnitClassification(self.unitID) == stringLower(expected)
  end
end

function unit:boss()
  local classification = UnitClassification(self.unitID)
  if spell == 'true' and (classification == 'rareelite' or classification == 'rare') then
    return true
  end
  if classification == 'worldboss' or LibBoss[UnitId(self.unitID)] then
    return true
  end
  return false
end

function unit:id(expected)
  return UnitID(self.unitID) == expected
end

function unit:moving()
  return GetUnitSpeed(self.unitID) ~= 0
end

function unit:class(expectedClass)
  local class, _, classID = UnitClass(self.unitID)

  if tonumber(expectedClass) then
    return tonumber(expectedClass) == classID
  else
    return expectedClass == class
  end
end

function unit:creatureType(expectedType)
  return UnitCreatureType(self.unitID) == expectedType
end

function unit:name(expectedName)
  return UnitName(self.unitID):lower():find(expectedName:lower()) ~= nil
end

function unit:level()
  return UnitLevel(self.unitID)
end

function unit:combat()
  return UnitAffectingCombat(self.unitID)
end

function unit:role(role)
  role = role:upper()

  local damageAliases = { "DAMAGE", "DPS", "DEEPS" }

  local targetRole = UnitGroupRolesAssigned(self.unitID)
  if targetRole == role then return true
  elseif role:find("HEAL") and targetRole == "HEALER" then return true
  else
    for i = 1, #damageAliases do
      if role == damageAliases[i] then return true end
    end
  end

  return false
end

function unit:deathin()
  local guid = UnitGUID(self.unitID)
  local name = GetUnitName(self.unitID)
  if name == "Training Dummy" or name == "Raider's Training Dummy" then
    return 99
  end
  if ProbablyEngine.module.combatTracker.enemy[guid] then
    return ProbablyEngine.module.combatTracker.enemy[guid]['ttd'] or 0
  end
  return 0
end

unit.ttd = unit.deathin

function unit:range()
  local minRange, maxRange = rangeCheck:GetRange(self.unitID)
  return maxRange
end

function unit:friend()
  return UnitCanAttack("player", self.unitID) ~= 1
end

function unit:enemy()
  return UnitCanAttack("player", self.unitID)
end

function unit:mana()
  if UnitExists(self.unitID) then
    return math.floor((UnitMana(self.unitID) / UnitManaMax(self.unitID)) * 100)
  end
  return 0
end

function unit:health()
  if UnitExists(self.unitID) then
    return math.floor((UnitHealth(self.unitID) / UnitHealthMax(self.unitID)) * 100)
  end
  return 0
end

function unit:runicpower()
  return UnitPower(self.unitID, SPELL_POWER_RUNIC_POWER)
end

function unit:threat()
  if UnitThreatSituation("player", self.unitID) then
    local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", self.unitID)
    return scaledPercent
  end
  return 0
end

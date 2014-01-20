-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local spell = {}
function spell:canCast(target)
  local spellIndex, spellBook = GetSpellBookIndex(self.spell)
  if not spellIndex then
    return false
  end

  local isUsable, notEnoughMana
  if spellBook ~= nil then
    isUsable, notEnoughMana = IsUsableSpell(spellIndex, spellBook)
  else
    isUsable, notEnoughMana = IsUsableSpell(spellId)
  end

  if not isUsable then return false end
  if notEnoughMana then return false end

  if target and target ~= "ground" then
    if not UnitExists(target) then return false end
    if not UnitIsVisible(target) then return false end
    if UnitIsDeadOrGhost(target) then return false end
    if spellBook ~= BOOKTYPE_PET then
      if spellBook ~= nil then
        if SpellHasRange(spellIndex, spellBook) == 1 then
          if IsSpellInRange(spellIndex, spellBook, target) == 0 then return false end
          if IsHarmfulSpell(spellIndex, spellBook) and not UnitCanAttack("player", target) then return false end
        end
      else
        if SpellHasRange(name) == 1 then
          if IsSpellInRange(name, target) == 0 then return false end
          if IsHarmfulSpell(name) and not UnitCanAttack("player", target) then return false end
        end
      end
    end
  end
  if UnitBuff("player", GetSpellInfo(80169)) then return false end -- Eat
  if UnitBuff("player", GetSpellInfo(87959)) then return false end -- Drink
  if UnitBuff("player", GetSpellInfo(11392)) then return false end -- Invis
  if UnitBuff("player", GetSpellInfo(3680)) then return false end  -- L. Invis

  if spellBook ~= nil and select(2, GetSpellCooldown(spellIndex, spellBook)) > 0 then return false end
  if spellBook == nil and select(2, GetSpellCooldown(spellId)) > 0 then return false end

  if spellBook == BOOKTYPE_PET then
    if not UnitExists('pet') then return false end
    if not target then return true end
    if ProbablyEngine.module.pet.casting then return false end
    if UnitCastingInfo('pet') ~= nil then return false end
    if UnitChannelInfo('pet') ~= nil then return false end
    return true
  end

  if self.stopCasting then
    SpellStopCasting()
    return true
  end

  if ProbablyEngine.module.player.casting == true then return false end
  if UnitChannelInfo('player') ~= nil then return false end

  return true
end
function spell.__call(self, target)
  if self:canCast(target) then
    CastSpellByName(self.spell, target)
  end
end
spell.__index = spell

local action = {}
function action.useItem(name, stopCasting)
end
function action.runMacro(name, stopCasting)
end
function action.spell(name, stopCasting)
  return setmetatable({ spell = name, stopCasting = stopCasting }, spell)
end

ProbablyEngine.dsl.register('action', action)

-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local tooltip = CreateFrame('GameTooltip', 'PETooltipReader', UIParent, 'GameTooltipTemplate')
tooltip:SetOwner(UIParent, 'ANCHOR_NONE')

local function scan(target, pattern, scanType)
  local i = 1
  while i <= 40 do
    if scanType == 'debuff' then
      tooltip:SetUnitDebuff(target, i)
    else
      tooltip:SetUnitBuff(target, i)
    end

    local text = string.lower(_G['PETooltipReader']:GetText())
    if text then
      if type(pattern) == 'string' then
        if string.match(text, pattern) then
          return true
        end
      elseif type(pattern) == 'table' then
        for j = 1, #pattern do
          if string.match(text, pattern[j]) then
            return true
          end
        end
      end
    end

    i = i + 1
  end

  return false
end

ProbablyEngine.tooltip = {}

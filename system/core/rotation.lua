-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local stringSub = string.sub

local debug = ProbablyEngine.debug
local emitter = ProbablyEngine.emitter
local Action = ProbablyEngine.dsl.dsl.action

local rotation = {}
ProbablyEngine.rotation = rotation

local specs = {}

local class, classFileName, classID = UnitClass('player')

-- Load Player Class
specs[classID] = { name = class, icon = 'Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES', coords = CLASS_ICON_TCOORDS[classFileName] }

-- Get Player Specilizations
for i = 1, GetNumSpecializationsForClassID(classID) do
  local id, specName, _, specIcon = GetSpecializationInfoForClassID(classID, i)
  specs[id] = { name = specName .. ' ' .. class, icon = specIcon }
end

local function parseAction(action)
  local actionType = type(action)
  if actionType == 'table' then
    return parseRow(action)
  elseif actionType == 'function' then
    return action
  elseif actionType == 'string' then
    local stopCasting
    if string.byte(action, 1) == 33 then
      stopCasting = true
      action = stringSub(action, 2)
    end
    
    if string.byte(action, 1) == 35 then
      return Action.item(stringSub(action, 2), stopCasting)
    elseif string.byte(action, 1) == 47 then
      return Action.macro(stringSub(action, 2), stopCasting)
    else
      return Action.spell(action, stopCasting)
    end
  elseif actionType == 'number' then
    return Action.spell(action)
  else
    error('Unexpected Action')
  end
end

local function falsify(bool)
  return function ()
    return bool
  end
end

local function evalRule(rule)
  local parsedRule = ProbablyEngine.dsl.dsl.rules.parse(rule)
  return function (action)
    local ok = parsedRule:evaluate(action)
    if type(ok) == 'function' then
      return ok(action)
    else
      return ok
    end
  end
end

local function parseRule(rule)
  local rulesType = type(rule)
  if rulesType == 'string' then
    return evalRule(rule)
  elseif rulesType == 'table' then
    local temp = {}
    for i = 1, #rule do
      temp[#temp] = parseRule(rule)
    end
    return temp
  elseif rulesType == 'nil' then
    return falsify(true)
  elseif rulesType == 'function' then
    return rule
  elseif rulesType == 'boolean' then
    return falsify(rule)
  else
    error('Unexpected Rule. Type: ' .. type(rulesType))
  end
end

-- TODO: Verify if target is an actual unit
local function parseRow(row)
  local action, rule, after, target = unpack(row)

  if after and not target then
    after, target = false, after
  end

  return { parseAction(action), parseRule(rule), after, target }
end

local function parse(obj)
  if type(obj) == 'table' then
    for i = 1, #obj do
      obj[i] = parseRow(obj[i])
    end
    return obj
  else
    error('Wtf not a table')
  end
end

local rot

function rotation.register(spec, options)
  if not specs[spec] or not options then return false end

  if string.find(debugstack(2, 1, 1), 'Probably\\rotations') then
    if not options.name then
      options.name = specs[spec].name
    end
  end

  if options.combat then
    options.combat = parse(options.combat)
  end

  if options.OOC then
    options.OOC = parse(options.OOC)
  end

  -- REMOVE
  rot = options

  debug.print('Loaded Rotation for ' .. options.name, 'rotation')
end

local function test2()
  if not rot.combat then return false end
  if not ProbablyEngine.module.player.combat then return false end

  for i = 1, #rot.combat do
    local action, rule, after, target = unpack(rot.combat[i])
    -- ProbablyEngine.debug.dump(rules)
    if rule(action, target) then
      action()
    end
  end
end

ProbablyEngine.timer.register('combatTest', test2, 300)

local function test()
  if not rot.OOC then return false end

  for i = 1, #rot.OOC do
    local action, rule, after, target = unpack(rot.OOC[i])
    -- ProbablyEngine.debug.dump(rules)
    if rule(action) then
      action(target)
    end
  end
end

ProbablyEngine.timer.register('oocTest', test, 300)

function rotation.register_custom()
end

-- emitter.once('addonLoaded', init)

-- local GetClassInfoByID = GetClassInfoByID

-- ProbablyEngine.rotation = {
--   rotations = { },
--   oocrotations =  { },
--   custom = { },
--   cdesc = { },
--   buttons = { },
--   specId = { },
--   classSpecId = { },
--   currentStringComp = "",
--   activeRotation = false,
--   activeOOCRotation = false,
-- }

-- ProbablyEngine.rotation.specId[62] = pelg('arcane_mage')
-- ProbablyEngine.rotation.specId[63] = pelg('fire_mage')
-- ProbablyEngine.rotation.specId[64] = pelg('frost_mage')
-- ProbablyEngine.rotation.specId[65] = pelg('holy_paladin')
-- ProbablyEngine.rotation.specId[66] = pelg('protection_paladin')
-- ProbablyEngine.rotation.specId[70] = pelg('retribution_paladin')
-- ProbablyEngine.rotation.specId[71] = pelg('arms_warrior')
-- ProbablyEngine.rotation.specId[72] = pelg('furry_warrior')
-- ProbablyEngine.rotation.specId[73] = pelg('protection_warrior')
-- ProbablyEngine.rotation.specId[102] = pelg('balance_druid')
-- ProbablyEngine.rotation.specId[103] = pelg('feral_combat_druid')
-- ProbablyEngine.rotation.specId[104] = pelg('guardian_druid')
-- ProbablyEngine.rotation.specId[105] = pelg('restoration_druid')
-- ProbablyEngine.rotation.specId[250] = pelg('blood_death_knight')
-- ProbablyEngine.rotation.specId[251] = pelg('frost_death_knight')
-- ProbablyEngine.rotation.specId[252] = pelg('unholy_death_knight')
-- ProbablyEngine.rotation.specId[253] = pelg('beast_mastery_hunter')
-- ProbablyEngine.rotation.specId[254] = pelg('marksmanship_hunter')
-- ProbablyEngine.rotation.specId[255] = pelg('survival_hunter')
-- ProbablyEngine.rotation.specId[256] = pelg('discipline_priest')
-- ProbablyEngine.rotation.specId[257] = pelg('holy_priest')
-- ProbablyEngine.rotation.specId[258] = pelg('shadow_priest')
-- ProbablyEngine.rotation.specId[259] = pelg('assassination_rogue')
-- ProbablyEngine.rotation.specId[260] = pelg('combat_rogue')
-- ProbablyEngine.rotation.specId[261] = pelg('subtlety_rogue')
-- ProbablyEngine.rotation.specId[262] = pelg('elemental_shaman')
-- ProbablyEngine.rotation.specId[263] = pelg('enhancement_shaman')
-- ProbablyEngine.rotation.specId[264] = pelg('restoration_shaman')
-- ProbablyEngine.rotation.specId[265] = pelg('affliction_warlock')
-- ProbablyEngine.rotation.specId[266] = pelg('demonology_warlock')
-- ProbablyEngine.rotation.specId[267] = pelg('destruction_warlock')
-- ProbablyEngine.rotation.specId[268] = pelg('brewmaster_monk')
-- ProbablyEngine.rotation.specId[269] = pelg('windwalker_monk')
-- ProbablyEngine.rotation.specId[270] = pelg('mistweaver_monk')

-- ProbablyEngine.rotation.classSpecId[62] = 8
-- ProbablyEngine.rotation.classSpecId[63] = 8
-- ProbablyEngine.rotation.classSpecId[64] = 8
-- ProbablyEngine.rotation.classSpecId[65] = 2
-- ProbablyEngine.rotation.classSpecId[66] = 2
-- ProbablyEngine.rotation.classSpecId[70] = 2
-- ProbablyEngine.rotation.classSpecId[71] = 1
-- ProbablyEngine.rotation.classSpecId[72] = 1
-- ProbablyEngine.rotation.classSpecId[73] = 1
-- ProbablyEngine.rotation.classSpecId[102] = 11
-- ProbablyEngine.rotation.classSpecId[103] = 11
-- ProbablyEngine.rotation.classSpecId[104] = 11
-- ProbablyEngine.rotation.classSpecId[105] = 11
-- ProbablyEngine.rotation.classSpecId[250] = 6
-- ProbablyEngine.rotation.classSpecId[251] = 6
-- ProbablyEngine.rotation.classSpecId[252] = 6
-- ProbablyEngine.rotation.classSpecId[253] = 3
-- ProbablyEngine.rotation.classSpecId[254] = 3
-- ProbablyEngine.rotation.classSpecId[255] = 3
-- ProbablyEngine.rotation.classSpecId[256] = 5
-- ProbablyEngine.rotation.classSpecId[257] = 5
-- ProbablyEngine.rotation.classSpecId[258] = 5
-- ProbablyEngine.rotation.classSpecId[259] = 4
-- ProbablyEngine.rotation.classSpecId[260] = 4
-- ProbablyEngine.rotation.classSpecId[261] = 4
-- ProbablyEngine.rotation.classSpecId[262] = 7
-- ProbablyEngine.rotation.classSpecId[263] = 7
-- ProbablyEngine.rotation.classSpecId[264] = 7
-- ProbablyEngine.rotation.classSpecId[265] = 9
-- ProbablyEngine.rotation.classSpecId[266] = 9
-- ProbablyEngine.rotation.classSpecId[267] = 9
-- ProbablyEngine.rotation.classSpecId[268] = 10
-- ProbablyEngine.rotation.classSpecId[269] = 10
-- ProbablyEngine.rotation.classSpecId[270] = 10

-- ProbablyEngine.rotation.register = function(specId, spellTable, arg1, arg2)
--   local name = ProbablyEngine.rotation.specId[specId] or GetClassInfoByID(specId)

--   local buttons, oocrotation = nil, nil

--   if type(arg1) == "table" then
--     oocrotation = arg1
--   end
--   if type(arg1) == "function" then
--     buttons = arg1
--   end
--   if type(arg2) == "table" then
--     oocrotation = arg2
--   end
--   if type(arg2) == "function" then
--     buttons = arg2
--   end

--   ProbablyEngine.rotation.rotations[specId] = spellTable

--   if oocrotation then
--     ProbablyEngine.rotation.oocrotations[specId] = oocrotation
--   end

--   if buttons and type(buttons) == 'function' then
--     ProbablyEngine.rotation.buttons[specId] = buttons
--   end

--   local name = ProbablyEngine.rotation.specId[specId] or GetClassInfoByID(specId)
--   ProbablyEngine.debug.print('Loaded Rotation for ' .. name, 'rotation')
-- end


-- ProbablyEngine.rotation.register_custom = function(specId, _desc, _spellTable, arg1, arg2)

--   local _oocrotation, _buttons = false

--   if type(arg1) == "table" then
--     _oocrotation = arg1
--   end
--   if type(arg1) == "function" then
--     _buttons = arg1
--   end
--   if type(arg2) == "table" then
--     _oocrotation = arg2
--   end
--   if type(arg2) == "function" then
--     _buttons = arg2
--   end

--   if not ProbablyEngine.rotation.custom[specId] then
--     ProbablyEngine.rotation.custom[specId] = { }
--   end

--   table.insert(ProbablyEngine.rotation.custom[specId], {
--     desc = _desc,
--     spellTable = _spellTable,
--     oocrotation = _oocrotation,
--     buttons = _buttons,
--   })

--   ProbablyEngine.debug.print('Loaded Custom Rotation for ' .. ProbablyEngine.rotation.specId[specId], 'rotation')
-- end

-- -- Lower memory used, no need in storing rotations for other classes
-- ProbablyEngine.rotation.auto_unregister = function()
--   local classId = select(3, UnitClass("player"))
--   for specId,_ in pairs(ProbablyEngine.rotation.rotations) do
--     if ProbablyEngine.rotation.classSpecId[specId] ~= classId and specId ~= classId then
--       local name = ProbablyEngine.rotation.specId[specId] or GetClassInfoByID(specId)
--       ProbablyEngine.debug.print('AutoUnloaded Rotation for ' .. name, 'rotation')
--       ProbablyEngine.rotation.classSpecId[specId] = nil
--       ProbablyEngine.rotation.specId[specId] = nil
--       ProbablyEngine.rotation.rotations[specId] = nil
--       ProbablyEngine.rotation.buttons[specId] = nil
--     end
--   end
--   collectgarbage('collect')
-- end

-- ProbablyEngine.rotation.add_buttons = function()
--   -- Default Buttons
--   if ProbablyEngine.rotation.buttons[ProbablyEngine.module.player.specID] then
--     ProbablyEngine.rotation.buttons[ProbablyEngine.module.player.specID]()
--   end

--   -- Custom Buttons
--   if ProbablyEngine.rotation.custom[ProbablyEngine.module.player.specID] then
--     for _, rotation in pairs(ProbablyEngine.rotation.custom[ProbablyEngine.module.player.specID]) do
--       if ProbablyEngine.rotation.currentStringComp == rotation.desc then
--         if rotation.buttons then
--           rotation.buttons()
--         end
--       end
--     end
--   end
-- end

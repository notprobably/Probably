-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local command = ProbablyEngine.command

command.register('pe')

command.register_handler('pe', { 'init', 'initmacro', 'initmacros' }, 'Create PE Macros', function () -- #PELG
  DeleteMacro('PE_Cycle')
  DeleteMacro('PE_Toggle');
  DeleteMacro('PE_Cooldowns');
  DeleteMacro('PE_Interrupts');
  DeleteMacro('PE_AoE');
  CreateMacro('PE_Cycle', 'achievement_Goblinhead', '/pe cycle');
  CreateMacro('PE_Toggle', 'achievement_Goblinhead', '/pe toggle');
  CreateMacro('PE_Cooldowns', 'Achievement_BG_winAB_underXminutes', '/pe cooldowns');
  CreateMacro('PE_Interrupts', 'Ability_Kick', '/pe interrupts');
  CreateMacro('PE_AoE', 'Ability_Druid_Starfall', '/pe aoe');
end)

command.register_handler('pe', { 'version', 'ver', 'v' }, pelg('help_version'), function ()
  ProbablyEngine.print('|cff' .. ProbablyEngine.addonColor .. 'ProbablyEngine ' .. pelg('build') .. '|r ' .. ProbablyEngine.version)
end)

command.register_handler('pe', { 'cycle', 'pew', 'run' }, pelg('help_cycle'), function ()
  ProbablyEngine.cycle(true)
end)

command.register_handler('pe', 'toggle', pelg('help_toggle'), function ()
  ProbablyEngine.buttons.toggle('MasterToggle')
end)

command.register_handler('pe', 'enable', 'Enable ProbablyEngine', function () -- #PELG
  ProbablyEngine.buttons.setActive('MasterToggle')
end)
command.register_handler('pe', 'disable', 'Disable ProbablyEngine', function () -- #PELG
  ProbablyEngine.buttons.setInactive('MasterToggle')
end)

command.register_handler('pe', { 'cd', 'cooldown', 'cooldowns' }, pelg('cooldowns_tooltip'), function ()
  ProbablyEngine.buttons.toggle('cooldowns')
end)

command.register_handler('pe', { 'kick', 'interrupts', 'interrupt', 'silence' }, pelg('interrupt_tooltip'), function ()
  ProbablyEngine.buttons.toggle('interrupt')
end)

command.register_handler('pe', { 'aoe', 'multitarget' }, pelg('multitarget_tooltip'), function ()
  ProbablyEngine.buttons.toggle('multitarget')
end)

command.register_handler('pe', { 'ct', 'combattracker', 'ut', 'unittracker', 'tracker' }, pelg('help_ct'), function ()
  UnitTracker.toggle()
end)

command.register_handler('pe', { 'al', 'log', 'actionlog' }, pelg('help_al'), function ()
  PE_ActionLog:Show()
end)

command.register_handler('pe', { 'lag', 'cycletime' }, 'Show Rotation Latency', function () -- #PELG
  PE_CycleLag:Show()
end)

command.register_handler('pe', { 'turbo', 'godmode' }, pelg('help_turbo'), function ()
  local state = ProbablyEngine.config.toggle('pe_turbo')
  if state then
    ProbablyEngine.print(pelg('turbo_enable'))
    SetCVar('maxSpellStartRecoveryOffset', 1)
    SetCVar('reducedLagTolerance', 10)
    ProbablyEngine.cycleTime = 10
  else
    ProbablyEngine.print(pelg('turbo_disable'))
    SetCVar('maxSpellStartRecoveryOffset', 1)
    SetCVar('reducedLagTolerance', 100)
    ProbablyEngine.cycleTime = 100
  end
end)

command.register_handler('pe', 'bvt', 'Toggle Button Text', function () -- #PELG
  local state = ProbablyEngine.config.toggle('buttonVisualText')
  ProbablyEngine.buttons.resetButtons()
  ProbablyEngine.rotation.add_buttons()
end)


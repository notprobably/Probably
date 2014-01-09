-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

ProbablyEngine.command = {}
local command = ProbablyEngine.command
local pPrint = ProbablyEngine.print

local handlers = {}

local function printHelp(name)
  if name == 'pe' then
    pPrint('|cff' .. ProbablyEngine.addonColor .. 'ProbablyEngine ' .. pelg('build') .. '|r ' .. ProbablyEngine.version)
  end
    
  for cmd, help in pairs(handlers[name]._help) do
    pPrint('|cff' .. ProbablyEngine.addonColor .. '/' .. name .. ' ' .. cmd .. '|r ' .. help)
  end
end
  
function command.register_handler(name, cmd, help, handler)
  if not handlers[name] then
    if type(name) == 'table' then
      for k, v in pairs(name) do
        pPrint(k)
        pPrint(v)
      end
    end
    return pPrint('Error, registering command for non existant handler: ' .. name) -- #PELG
  end

  local commandType = type(cmd)
  if commandType == 'string' then
    handlers[name][cmd] = handler
    handlers[name]._help[cmd] = help
  elseif commandType == 'table' then
    for i = 1, #cmd do
      handlers[name][cmd[i]] = handler
    end
    handlers[name]._help[cmd[1]] = help
  else
    pPrint(pelg('unknown_type') .. ': ' .. commandType)
  end
end

local function defaultHandler(name, message)
  local cmd, text = message:match('^(%S*)%s*(.*)$')
  if handlers[name][cmd] then
    handlers[name][cmd](text)
  else
    printHelp(name)
  end
end

function command.register(cmd, handler)
  local name = 'PE_' .. cmd
  _G['SLASH_' .. name .. '1'] = '/' .. cmd

  if handler then
    SlashCmdList[name] = handler
    return
  end

  handlers[cmd] = { _help = {} }
  SlashCmdList[name] = function (message, editbox)
    defaultHandler(cmd, message)
  end

  command.register_handler(cmd, { 'help', '?', 'wat' }, pelg('help_help'), function ()
    printHelp(cmd)
  end)
end

-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local emitter = ProbablyEngine.emitter
local pelg = ProbablyEngine.locale.get
local build = ProbablyEngine.build
local stringFormat = string.format

local function addonLoaded(addon)
  if addon ~= ProbablyEngine.addonName then return end

  -- load all our config data
  ProbablyEngine.config.load(ProbablyEngine_ConfigData)

  -- load our previous button states
  -- ProbablyEngine.buttons.loadStates()

  -- update tracker state
  -- UnitTracker.toggle(true)

  -- Turbo
  ProbablyEngine.config.read('pe_turbo', false)

  -- Dynamic Cycle
  ProbablyEngine.config.read('pe_dynamic', false)

  ProbablyEngine.version = 'Development Release'
  if build then
    ProbablyEngine.version = string.format('%s v%d (%s)', pelg('build'), build.version, build.commit)
  end

  emitter.emit('addonLoaded')
end

ProbablyEngine.listener.register('ADDON_LOADED', addonLoaded)

-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local LibDispellable = LibStub('LibDispellable-1.0')

local unit = ProbablyEngine.dsl.get('rules').get('unit').unit

local patterns = {}

patterns.status = {}
patterns.status.charm = { '^charmed' }
patterns.status.disarm = { 'disarmed' }
patterns.status.disorient = { '^disoriented' }
patterns.status.dot = { 'damage every.*sec', 'damage per.*sec' }
patterns.status.fear = {
  '^horrified', '^fleeing', '^feared', '^intimidated', '^cowering in fear',
  '^running in fear', '^compelled to flee'
}
patterns.status.incapacitate = {
  '^incapacitated', '^sapped'
}
patterns.status.misc = {
  'unable to act', '^bound', '^frozen.$', '^cannot attack or cast spells',
  '^shackled.$'
}
patterns.status.root = {
    '^rooted', '^immobil', '^webbed', 'frozen in place', '^paralyzed',
    '^locked in place', '^pinned in place'
}
patterns.status.silence = {
    '^silenced'
}
patterns.status.sleep = {
    '^asleep'
}
patterns.status.snare = {
    '^movement.*slowed', 'movement speed reduced', '^slowed by', '^dazed',
    '^reduces movement speed'
}
patterns.status.stun = {
    '^stunned', '^webbed'
}

patterns.immune = {}
patterns.immune.all = {
    'dematerialize', 'deterrence', 'divine shield', 'ice block'
}
patterns.immune.charm = {
    'bladestorm', 'desecrated ground', 'grounding totem effect', 'lichborne'
}
patterns.immune.disorient = {
    'bladestorm', 'desecrated ground'
}
patterns.immune.fear = {
    'berserker rage', 'bladestorm', 'desecrated ground', 'grounding totem',
    'lichborne', 'nimble brew'
}
patterns.immune.incapacitate = {
    'bladestorm', 'desecrated ground'
}
patterns.immune.melee = {
    'dispersion', 'evasion', 'hand of protection', 'ring of peace', 'touch of karma'
}
patterns.immune.misc = {
    'bladestorm', 'desecrated ground'
}
patterns.immune.silence = {
    'devotion aura', 'inner focus', 'unending resolve'
}
patterns.immune.polly = {
    'immune to polymorph'
}
patterns.immune.sleep = {
    'bladestorm', 'desecrated ground', 'lichborne'
}
patterns.immune.snare = {
    'bestial wrath', 'bladestorm', 'death\'s advance', 'desecrated ground',
    'dispersion', 'hand of freedom', 'master\'s call', 'windwalk totem'
}
patterns.immune.spell = {
    'anti-magic shell', 'cloak of shadows', 'diffuse magic', 'dispersion',
    'massspell reflection', 'ring of peace', 'spell reflection', 'touch of karma'
}
patterns.immune.stun = {
    'bestial wrath', 'bladestorm', 'desecrated ground', 'icebound fortitude',
    'grounding totem', 'nimble brew'
}

local scan
local emitter = ProbablyEngine.emitter
local function init()
  scan = ProbablyEngine.module.tooltip.scan
end
emitter.once('addonLoaded', init)

function unit:state()
  return {
    purge = function (action)
      if action.spell then
        return LibDispellable:CanDispelWith(self.unitID, GetSpellID(action.spell))
      else
        return LibDispellable:CanDispelWith(self.unitID, GetSpellID(action))
      end
    end,

    charm = function () return scan(self.unitID, patterns.status.charm, 'debuff') end,
    disarm = function () return scan(self.unitID, patterns.status.disarm, 'debuff') end,
    disorient = function () return scan(self.unitID, patterns.status.disorient, 'debuff') end,
    dot = function () return scan(self.unitID, patterns.status.dot, 'debuff') end,
    fear = function () return scan(self.unitID, patterns.status.fear, 'debuff') end,
    incapacitate = function () return scan(self.unitID, patterns.status.incapacitate, 'debuff') end,
    misc = function () return scan(self.unitID, patterns.status.misc, 'debuff') end,
    silence = function () return scan(self.unitID, patterns.status.silence, 'debuff') end,
    sleep = function () return scan(self.unitID, patterns.status.sleep, 'debuff') end,
    snare = function () return scan(self.unitID, patterns.status.snare, 'debuff') end,
    stun = function () return scan(self.unitID, patterns.status.stun, 'debuff') end
  }
end

function unit:immune()
  return {
    all = function () return scan(self.unitID, patterns.immune.all) end,
    charm = function () return scan(self.unitID, patterns.immune.charm) end,
    disorient = function () return scan(self.unitID, patterns.immune.disorient) end,
    fear = function () return scan(self.unitID, patterns.immune.fear) end,
    incapacitate = function () return scan(self.unitID, patterns.immune.incapacitate) end,
    melee = function () return scan(self.unitID, patterns.immune.melee) end,
    misc = function () return scan(self.unitID, patterns.immune.misc) end,
    silence = function () return scan(self.unitID, patterns.immune.silence) end,
    poly = function () return scan(self.unitID, patterns.immune.poly) end,
    sleep = function () return scan(self.unitID, patterns.immune.sleep) end,
    snare = function () return scan(self.unitID, patterns.immune.snare) end,
    spell = function () return scan(self.unitID, patterns.immune.spell) end,
    stun = function () return scan(self.unitID, patterns.immune.stun) end
  }
end

-- SPEC ID 104
ProbablyEngine.rotation.register(104, {

  --------------------
  -- Start Rotation --
  --------------------

  --Feck you need bear form
  { "Bear Form", { "!player.buff(Bear Form)" }},

  -- Interrupts
  { "Faerie Fire", "modifier.interrupts", "!modifier.last(Mighty Bash)" },
  { "Mighty Bash" , "modifier.interrupts", "!modifier.last(Skull Bash)" },

  -- Ress target-Instantly
  { "Rebirth", { "target.dead", "player.buff(Dream of Cenarius)" }, "target" },
  { "Rebirth", { "mouseover.dead", "player.buff(Dream of Cenarius)" }, "mouseover" },
  
  -- Survival
  {{
  { "Renewal", { "player.health <= 30" }},
  { "Renewal", { "player.health <= 50", "player.buff(Might of Ursoc)" }},
  { "Survival Instincts", { "player.health <= 40" }},
  { "Might of Ursoc", { "player.health <= 50" }},
  { "Barkskin", { "player.health <= 90" }},
  { "Bone Shield", { "player.buff(Symbiosis)" }},
  { "Elusive Brew", { "player.health <= 90", "player.buff(Symbiosis)" }},
  { "#Healthstone", { "player.health <= 50" }},
  }, { "toggle.Survival" }},
  { "Frenzied Regeneration", { "player.health <= 80", "!player.buff", "!modifier.last(Frenzied Regeneration)" }},
  { "Savage Defense", { "player.health <= 95", "!player.buff", "!modifier.last(Savage Defense)" }},
  { "Healing Touch", { "player.health <= 90", "player.buff(Dream of Cenarius)" }}, --self
  { "Healing Touch", { "targettarget.health <= 90", "player.buff(Dream of Cenarius)" }, "targettarget" }, --self or other tank
  { "Healing Touch", { "lowest.health <= 65", "player.buff(Dream of Cenarius)" }, "lowest" }, --anyone in raid
  
  --AOE
  { "Swipe", { "modifier.multitarget", "target.range <= 5" }}, 

  -- Cooldowns
  {{
  { "Nature's Vigil", { "player.spell(Berserk).cooldown = 0" }},
  { "Nature's Vigil", { "player.spell(Incarnation: Son of Ursoc).cooldown = 0" }},
  { "Incarnation: Son of Ursoc", { "player.buff(Nature's Vigil)" }},
  { "Berserk", { "player.time > 5", "!player.buff(Incarnation: Son of Ursoc)", "player.buff(Nature's Vigil).duration > 10" }},
  }, { "!target.dead", "target.range <= 5", "player.spell(Nature's Vigil).exists", "modifier.cooldowns" }},
  {{
  { "Incarnation: Son of Ursoc" },
  { "Berserk", { "player.time >= 90", "!player.buff(Incarnation: Son of Ursoc)" }},
  }, { "!target.dead", "target.range <= 5", "!player.spell(Nature's Vigil).exists", "modifier.cooldowns" }},

  -- Mob Control
  { "Enrage", { "player.rage < 70" }},
  { "Faerie Fire", { "target.debuff(Weakened Armor).duration < 3" }},
  { "Thrash", { "target.range <= 5", "target.debuff.duration < 3" }},
  { "Maul", { "player.buff(Tooth and Claw)", "!modifier.last(Maul)" }},
  { "Maul", { "player.rage >= 70", "!modifier.last(Maul)"  }},
  { "Maul", { "player.treat < 100", "!modifier.last(Maul)"  }},
  { "Mangle" },
  { "Lacerate", { "target.debuff.duration < 3", "!modifier.multitarget" }},
  { "Lacerate", { "!modifier.last(Lacerate)" }},
  { "Swipe", { "target.range <= 5", "modifier.enemies > 3" }},
  { "Faerie Fire" },
  { "Thrash", { "target.range <= 5" }},
  { "Swipe", { "target.range <= 5" }},

  ------------------
  -- End Rotation --
  ------------------

},
{

  ---------------
  -- OOC Begin --
  ---------------

{ "Mark of the Wild", { "!lowest.buff(Mark of the Wild).any", "!lowest.buff(Blessing of Kings).any", "!lowest.buff(Legacy of the Emperor).any", "lowest.range <= 30", "player.form = 0" }, "lowest" }

  -------------
  -- OOC End --
  -------------

},
function()
ProbablyEngine.toggle.create('Survival', 'Interface\\Icons\\Ability_druid_tigersroar','Survivability','Enable or Disable the usage of Survivability Cooldowns')
end)

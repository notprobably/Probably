-- SPEC ID 251
ProbablyEngine.rotation.register(251, {
  
  --------------------
  -- Start Rotation --
  --------------------
  
  -- Survival
  -- Death Pact Macro
  { "!/cast Raise Dead\n/cast Death Pact", { 
    "player.health < 35", "player.spell(Death Pact).cooldown", 
    "player.spell(Raise Dead).cooldown", 
    "player.spell.usable(Death Pact)" 
  }},
  
  -- Keybinds
  { "Death and Decay", "modifier.shift", "ground" },
  { "Chains of Ice", "modifier.control" },
  
  -- Cooldowns
  -- w/o Modifier
  { "Horn of Winter" },
  -- w/ Modifier
  { "Pillar of Frost", "modifier.cooldowns" },
  { "Raise Dead", "modifier.cooldowns" },
  
  { "Empower Rune Weapon", {
    "modifier.cooldowns", 
    "player.runicpower <= 70", 
    "player.runes(blood).count = 0", 
    "player.runes(unholy).count = 0", 
    "player.runes(frost).count = 0", 
    "player.runes(death).count = 0",
  }},

  -- Disease Control
  { "Outbreak", {
    "target.debuff(Frost Fever).duration < 3", 
    "target.debuff(Blood Plague).duration <3", 
  }, "target" },
  
  { "Howling Blast", "target.debuff(Frost Fever).duration < 3" },
  { "Plague Strike", "target.debuff(Blood Plague).duration < 3" },
  
 -- AoE Rotation
  { "Pestilence", "modifier.multitarget" },
  { "Howling Blast", "modifier.multitarget" },
  { "Frost Strike", "modifier.multitarget" },
  
  { "Plague Strike", {
    "modifier.multitarget", 
    "!modifier.last(Plague Strike)", 
    "player.spell(Death and Decay).cooldown",
  }},
  
  -- Rotation
  { "Soul Reaper", {
    "!modifier.multitarget", 
    "target.health < 35",
  }},
  
  { "Howling Blast", {
    "!modifier.multitarget", 
    "player.buff(Freezing Fog)",
  }},
  
  { "Obliterate", {
    "!modifier.multitarget", 
    "player.buff(Killing Machine)",
  }},
  
  { "Obliterate", {
    "!modifier.multitarget",
    "player.runicpower <= 75",
  }},
  
  { "Frost Strike", {
    "!modifier.multitarget", 
    "!player.buff(Killing Machine)",
  }},
  
  ------------------
  -- End Rotation --
  ------------------
  
  },{
  
  -- OOC
  -- Buffs
  { "Horn of Winter", "!player.buff(Horn of Winter)" },
  { "Path of Frost", "!player.buff(Path of Frost).any" },
  
  -- Keybinds
  { "Army of the Dead", "modifier.alt" },
  { "Death Grip", "modifier.control" },

  }
)

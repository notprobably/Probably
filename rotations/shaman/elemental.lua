-- SPEC ID 262
ProbablyEngine.rotation.register(262, {

  -------------------
  -- Start Racials --
  -------------------
  
  -- =^*~ Alliance ~*^= --
  -- Dwarves
  { "Stoneform", "player.health <= 65" },

  -- Draenei
  { "Gift of the Naaru", "player.health <= 70", "player" },
 
  -- <,&~ Horde ~&,> --
  -- Goblins
  { "Rocket Barrage", "player.moving" },
  
  -- _,-=%Pandaren%=-,_ --
  { "Quaking Palm", "modifier.interrupts" },
  
  -----------------
  -- End Racials --
  -----------------
  
  --------------------
  -- Start Rotation --
  --------------------
  
  -- Buffs
  { "Flametongue Weapon", "!player.enchant.mainhand" },
  { "Lightning Shield", "!player.buff(Lightning Shield)" },

  -- Moving Rotation
  { "Lightning Bolt", {  "player.moving", "!player.buff(Spiritwalker's Grace)" } },

  -- AoE
  { "Earthquake", "modifier.shift", "ground" },

  -- Cooldowns
  { "Shamanistic Rage", "modifier.cooldowns" },
  { "Stormlash Totem", "modifier.cooldowns" },
  { "Fire Elemental Totem", "modifier.cooldowns" },
  { "Ascendance", { "modifier.cooldowns", "!player.buff(Ascendance)" } },

  -- Totems
  { "Searing Totem", { "!player.totem(Fire Elemental Totem)", "!player.totem(Searing Totem)" } },
  { "Healing Stream", "!totem(Healing Stream)" },

  -- Rotation
  { "Flame Shock", "target.debuff(Flame Shock).duration <= 3" },
  { "Lava Burst" },
  { "Elemental Blast" },
  { "Earth Shock", "player.buff(Lightning Shield).count >= 6" },

  -- Aoe
  { "Chain Lightning", "modifier.multitarget" },

  -- Filler
  { "Lightning Bolt" }
  
  ------------------
  -- End Rotation --
  ------------------
  
}, {

  ---------------
  -- OOC Begin --
  ---------------
  
  -- Buffs
  { "Flametongue Weapon", "!player.enchant.mainhand" },
  { "Lightning Shield", "!player.buff(Lightning Shield)" },

  -- Heal
  { "Healing Stream Totem", "player.health < 100" },
  
  -------------
  -- OOC End --
  -------------
  
})

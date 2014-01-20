-- Class ID 10 - Four Line Killing Machine
local monk = {}

monk.combat = {
  -- Roll
  { "Roll", "modifier.shift" },

  -- Rotation
  { "Tiger Palm", "player.buff(Tiger Power).duration < 3" },
  { "Blackout Kick" },
  { "Jab" },
}

monk.OOC = {
  -- Roll
  { "Roll", "modifier.shift" },
}

ProbablyEngine.rotation.register(10, monk)

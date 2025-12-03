-- Game module initialization
-- This module will contain game state management and coordination

local Playfield = require("game/playfield")
local CollisionDetector = require("game/collision")

return {
    Playfield = Playfield,
    CollisionDetector = CollisionDetector,
}

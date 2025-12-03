-- Game module initialization
-- This module will contain game state management and coordination

local Playfield = require("game/playfield")
local CollisionDetector = require("game/collision")
local GameState = require("game/state")
local ScoreManager = require("game/score")
local InputHandler = require("input/init")

return {
    Playfield = Playfield,
    CollisionDetector = CollisionDetector,
    GameState = GameState,
    ScoreManager = ScoreManager,
    InputHandler = InputHandler,
}

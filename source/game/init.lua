-- Game module initialization
-- This module loads all game components

-- Check if we're in Playdate environment (has import) or standard Lua (has require)
if import then
    -- Playdate environment - use import
    import "game/playfield"
    import "game/collision"
    import "game/state"
    import "game/score"
    import "input/init"
    import "game/manager"
else
    -- Standard Lua environment - use require
    local Playfield = require("game/playfield")
    local CollisionDetector = require("game/collision")
    local GameState = require("game/state")
    local ScoreManager = require("game/score")
    local InputHandler = require("input/init")
    local GameManager = require("game/manager")
    
    return {
        Playfield = Playfield,
        CollisionDetector = CollisionDetector,
        GameState = GameState,
        ScoreManager = ScoreManager,
        InputHandler = InputHandler,
        GameManager = GameManager,
    }
end

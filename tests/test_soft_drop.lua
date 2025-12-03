-- Property-based test for soft drop
-- Feature: playdate-tetris, Property 11: Soft drop increases fall speed
-- Validates: Requirements 4.1, 4.2

local lqc = require("lib/lqc")
local pieces = require("pieces/init")
local game = require("game/init")

-- Custom generator for game state with active piece
local Generator = {}
Generator.__index = Generator

function Generator:new(generate_fn)
    local gen = {
        generate = generate_fn
    }
    setmetatable(gen, Generator)
    return gen
end

local function generateGameStateWithPiece()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        local factory = pieces.TetrominoFactory:new()
        local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
        
        return gameState
    end)
end

-- Property 11: Soft drop increases fall speed
-- For any game state, holding the down button should decrease the fall interval,
-- and releasing it should restore the original interval based on current level
local prop_soft_drop = lqc.property("soft drop increases fall speed",
    lqc.forall(
        {generateGameStateWithPiece()},
        function(gameState)
            -- Get original fall interval
            local originalInterval = gameState.fallInterval
            
            if originalInterval <= 0 then
                return false, "Fall interval should be positive"
            end
            
            -- Enable soft drop
            gameState:setSoftDrop(true)
            local softDropInterval = gameState.fallInterval
            
            -- Soft drop should make falling faster (smaller interval)
            if softDropInterval >= originalInterval then
                return false, "Soft drop should decrease fall interval (increase speed)"
            end
            
            -- Disable soft drop
            gameState:setSoftDrop(false)
            local restoredInterval = gameState.fallInterval
            
            -- Fall interval should be restored to original
            if restoredInterval ~= originalInterval then
                return false, "Disabling soft drop should restore original fall interval"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_soft_drop)

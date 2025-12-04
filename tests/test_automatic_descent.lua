-- Property-based test for automatic piece descent
-- Feature: vibetris, Property 2: Automatic piece descent
-- Validates: Requirements 1.2

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 2: Automatic piece descent
-- For any active Tetromino and elapsed fall interval, the piece's y position 
-- should increase by exactly 1 row
local prop_automatic_descent = lqc.property("automatic descent moves piece down by 1",
    lqc.forall(
        {lqc.generators.int(1, 100)}, -- Dummy generator
        function(dummy)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
            
            -- Get initial piece position
            local initialY = gameState.currentPiece.y
            
            -- Simulate fall interval passing
            gameState:update(gameState.fallInterval)
            
            -- Piece should have moved down by 1
            local expectedY = initialY + 1
            local actualY = gameState.currentPiece.y
            
            if actualY ~= expectedY then
                return false, string.format(
                    "After fall interval, piece at y=%d, expected y=%d", 
                    actualY, expectedY
                )
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_automatic_descent)

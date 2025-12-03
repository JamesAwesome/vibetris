-- Property-based test for pause behavior
-- Feature: playdate-tetris, Property 20: Pause prevents game updates
-- Validates: Requirements 9.2

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 20: Pause prevents game updates
-- For any game state where state is "paused", Tetromino positions and game 
-- timers should not change over update cycles
local prop_pause_prevents_updates = lqc.property("pause prevents game updates",
    lqc.forall(
        {lqc.generators.int(1, 100)}, -- Delta time for update (in milliseconds)
        function(dt_ms)
            local dt = dt_ms / 100.0 -- Convert to seconds (0.01 to 1.0)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local collisionDetector = game.CollisionDetector
            local gameState = game.GameState:new(playfield, factory, collisionDetector)
            
            -- Capture initial state
            local initialPieceX = gameState.currentPiece.x
            local initialPieceY = gameState.currentPiece.y
            local initialFallTimer = gameState.fallTimer
            local initialLockTimer = gameState.lockTimer
            local initialIsLocking = gameState.isLocking
            
            -- Pause the game
            gameState:pause()
            
            -- Verify state is paused
            if gameState.state ~= "paused" then
                return false, "Game state should be 'paused' after calling pause()"
            end
            
            -- Update the game (should have no effect)
            gameState:update(dt)
            
            -- Verify piece position hasn't changed
            if gameState.currentPiece.x ~= initialPieceX then
                return false, string.format("Piece X changed from %d to %d while paused", 
                    initialPieceX, gameState.currentPiece.x)
            end
            
            if gameState.currentPiece.y ~= initialPieceY then
                return false, string.format("Piece Y changed from %d to %d while paused", 
                    initialPieceY, gameState.currentPiece.y)
            end
            
            -- Verify timers haven't changed
            if gameState.fallTimer ~= initialFallTimer then
                return false, string.format("Fall timer changed from %.2f to %.2f while paused", 
                    initialFallTimer, gameState.fallTimer)
            end
            
            if gameState.lockTimer ~= initialLockTimer then
                return false, string.format("Lock timer changed from %.2f to %.2f while paused", 
                    initialLockTimer, gameState.lockTimer)
            end
            
            if gameState.isLocking ~= initialIsLocking then
                return false, "Lock state changed while paused"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_pause_prevents_updates)

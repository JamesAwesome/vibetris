-- Property-based test for spawn after lock
-- Feature: playdate-tetris, Property 4: Spawn after lock
-- Validates: Requirements 1.4

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 4: Spawn after lock
-- For any locked Tetromino, a new Tetromino should appear at the spawn 
-- location immediately after locking
local prop_spawn_after_lock = lqc.property("new piece spawns after lock",
    lqc.forall(
        {lqc.generators.int(1, 100)}, -- Dummy generator
        function(dummy)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
            
            -- Record the original piece type
            local originalPieceType = gameState.currentPiece.type
            
            -- Move piece to bottom
            while gameState:canMoveDown() do
                gameState.currentPiece:move(0, 1, playfield, game.CollisionDetector)
            end
            
            -- Trigger lock by waiting for lock delay
            gameState:update(gameState.fallInterval + gameState.lockDelay)
            
            -- A new piece should have spawned
            if gameState.currentPiece == nil then
                return false, "No piece spawned after lock"
            end
            
            -- New piece should be at spawn location (y=0)
            if gameState.currentPiece.y ~= 0 then
                return false, string.format(
                    "New piece spawned at y=%d, expected y=0", 
                    gameState.currentPiece.y
                )
            end
            
            -- New piece should be at center (x=3 or x=4)
            if gameState.currentPiece.x ~= 3 and gameState.currentPiece.x ~= 4 then
                return false, string.format(
                    "New piece spawned at x=%d, expected x=3 or x=4", 
                    gameState.currentPiece.x
                )
            end
            
            -- New piece should start at rotation 0
            if gameState.currentPiece.rotation ~= 0 then
                return false, string.format(
                    "New piece spawned at rotation=%d, expected rotation=0", 
                    gameState.currentPiece.rotation
                )
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_spawn_after_lock)

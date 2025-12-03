-- Property-based test for lock delay
-- Feature: playdate-tetris, Property 3: Lock delay preserves piece state
-- Validates: Requirements 1.3

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 3: Lock delay preserves piece state
-- For any Tetromino that cannot move downward, the piece should remain in its 
-- current position until lock delay expires, then its blocks should be added 
-- to the playfield grid
local prop_lock_delay = lqc.property("lock delay preserves piece state until expiry",
    lqc.forall(
        {lqc.generators.int(1, 100)}, -- Dummy generator
        function(dummy)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
            
            -- Move piece to bottom
            while gameState:canMoveDown() do
                gameState.currentPiece:move(0, 1, playfield, game.CollisionDetector)
            end
            
            -- Record piece position and type
            local pieceX = gameState.currentPiece.x
            local pieceY = gameState.currentPiece.y
            local pieceType = gameState.currentPiece.type
            local pieceRotation = gameState.currentPiece.rotation
            
            -- Trigger a fall attempt to start lock delay
            gameState:update(gameState.fallInterval)
            
            -- Update with time less than lock delay (but not enough to trigger another fall)
            local shortTime = gameState.lockDelay * 0.5
            gameState:update(shortTime)
            
            -- Piece should still be the current piece (not locked yet)
            if gameState.currentPiece.type ~= pieceType then
                return false, "Piece locked before lock delay expired"
            end
            
            -- Position should be preserved
            if gameState.currentPiece.x ~= pieceX or gameState.currentPiece.y ~= pieceY then
                return false, "Piece position changed during lock delay"
            end
            
            -- Rotation should be preserved
            if gameState.currentPiece.rotation ~= pieceRotation then
                return false, "Piece rotation changed during lock delay"
            end
            
            -- Now update with enough time to exceed lock delay
            gameState:update(gameState.lockDelay)
            
            -- Piece should now be locked (new piece spawned)
            if gameState.currentPiece.type == pieceType and 
               gameState.currentPiece.x == pieceX and 
               gameState.currentPiece.y == pieceY then
                return false, "Piece not locked after lock delay expired"
            end
            
            -- Check that blocks were added to playfield
            local blocks = pieces.Tetromino:new(pieceType, pieceX, pieceY, pieceRotation):getBlocks()
            local allBlocksLocked = true
            for i = 1, #blocks do
                local block = blocks[i]
                local gridX = block.x + 1
                local gridY = block.y + 1
                if not playfield:isOccupied(gridX, gridY) then
                    allBlocksLocked = false
                    break
                end
            end
            
            if not allBlocksLocked then
                return false, "Not all blocks were locked to playfield"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_lock_delay)

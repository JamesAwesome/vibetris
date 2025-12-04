-- Property-based test for next piece availability
-- Feature: vibetris, Property 19: Next piece is always available
-- Validates: Requirements 7.1

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 19: Next piece is always available
-- For any game state where state is "playing", there should always be a 
-- valid next Tetromino defined
local prop_next_piece_available = lqc.property("next piece is always available during play",
    lqc.forall(
        {lqc.generators.int(1, 50)}, -- Number of pieces to spawn
        function(numPieces)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local collisionDetector = game.CollisionDetector
            local gameState = game.GameState:new(playfield, factory, collisionDetector)
            
            -- Valid piece types
            local validTypes = {I = true, O = true, T = true, S = true, Z = true, J = true, L = true}
            
            -- Check initial state
            if gameState.state == "playing" then
                if not gameState.nextPiece then
                    return false, "Next piece is nil at game start"
                end
                
                if not validTypes[gameState.nextPiece] then
                    return false, string.format("Next piece has invalid type: %s", tostring(gameState.nextPiece))
                end
            end
            
            -- Spawn multiple pieces and verify next piece is always available
            for i = 1, numPieces do
                -- Only check if game is still playing
                if gameState.state == "playing" then
                    -- Verify next piece exists
                    if not gameState.nextPiece then
                        return false, string.format("Next piece is nil after spawning %d pieces", i)
                    end
                    
                    -- Verify next piece is a valid type
                    if not validTypes[gameState.nextPiece] then
                        return false, string.format("Next piece has invalid type '%s' after spawning %d pieces", 
                            tostring(gameState.nextPiece), i)
                    end
                    
                    -- Lock current piece to spawn next one
                    gameState:lockCurrentPiece()
                    
                    -- After locking, if still playing, next piece should still be available
                    if gameState.state == "playing" then
                        if not gameState.nextPiece then
                            return false, string.format("Next piece is nil after locking piece %d", i)
                        end
                        
                        if not validTypes[gameState.nextPiece] then
                            return false, string.format("Next piece has invalid type '%s' after locking piece %d", 
                                tostring(gameState.nextPiece), i)
                        end
                    end
                else
                    -- Game over, stop testing
                    break
                end
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_next_piece_available)

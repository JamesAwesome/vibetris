-- Property-based test for pause round trip
-- Feature: playdate-tetris, Property 21: Pause-unpause round trip
-- Validates: Requirements 9.3

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 21: Pause-unpause round trip
-- For any game state, transitioning to "paused" then back to "playing" should 
-- preserve all game state (piece positions, score, level, playfield)
local prop_pause_round_trip = lqc.property("pause-unpause preserves game state",
    lqc.forall(
        {lqc.generators.int(0, 100)}, -- Dummy generator
        function(dummy)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local collisionDetector = game.CollisionDetector
            local gameState = game.GameState:new(playfield, factory, collisionDetector)
            local scoreManager = game.ScoreManager:new()
            
            -- Add some score and lines to make state more interesting
            scoreManager:addLines(3)
            
            -- Lock a few blocks to the playfield
            playfield.grid[19][5] = "I"
            playfield.grid[19][6] = "O"
            
            -- Capture complete initial state
            local initialState = {
                gameState = gameState.state,
                pieceX = gameState.currentPiece.x,
                pieceY = gameState.currentPiece.y,
                pieceRotation = gameState.currentPiece.rotation,
                pieceType = gameState.currentPiece.type,
                nextPiece = gameState.nextPiece,
                fallTimer = gameState.fallTimer,
                lockTimer = gameState.lockTimer,
                isLocking = gameState.isLocking,
                score = scoreManager:getScore(),
                level = scoreManager:getLevel(),
                totalLines = scoreManager:getTotalLines(),
                -- Capture playfield state
                playfieldBlock1 = playfield.grid[19][5],
                playfieldBlock2 = playfield.grid[19][6],
            }
            
            -- Pause the game
            gameState:pause()
            
            -- Verify it's paused
            if gameState.state ~= "paused" then
                return false, "Game should be paused after calling pause()"
            end
            
            -- Unpause the game
            gameState:unpause()
            
            -- Verify it's playing again
            if gameState.state ~= "playing" then
                return false, "Game should be playing after calling unpause()"
            end
            
            -- Verify all state is preserved
            if gameState.currentPiece.x ~= initialState.pieceX then
                return false, string.format("Piece X changed from %d to %d after round trip", 
                    initialState.pieceX, gameState.currentPiece.x)
            end
            
            if gameState.currentPiece.y ~= initialState.pieceY then
                return false, string.format("Piece Y changed from %d to %d after round trip", 
                    initialState.pieceY, gameState.currentPiece.y)
            end
            
            if gameState.currentPiece.rotation ~= initialState.pieceRotation then
                return false, string.format("Piece rotation changed from %d to %d after round trip", 
                    initialState.pieceRotation, gameState.currentPiece.rotation)
            end
            
            if gameState.currentPiece.type ~= initialState.pieceType then
                return false, string.format("Piece type changed from %s to %s after round trip", 
                    initialState.pieceType, gameState.currentPiece.type)
            end
            
            if gameState.nextPiece ~= initialState.nextPiece then
                return false, "Next piece changed after round trip"
            end
            
            if gameState.fallTimer ~= initialState.fallTimer then
                return false, string.format("Fall timer changed from %.2f to %.2f after round trip", 
                    initialState.fallTimer, gameState.fallTimer)
            end
            
            if gameState.lockTimer ~= initialState.lockTimer then
                return false, string.format("Lock timer changed from %.2f to %.2f after round trip", 
                    initialState.lockTimer, gameState.lockTimer)
            end
            
            if gameState.isLocking ~= initialState.isLocking then
                return false, "Lock state changed after round trip"
            end
            
            if scoreManager:getScore() ~= initialState.score then
                return false, string.format("Score changed from %d to %d after round trip", 
                    initialState.score, scoreManager:getScore())
            end
            
            if scoreManager:getLevel() ~= initialState.level then
                return false, string.format("Level changed from %d to %d after round trip", 
                    initialState.level, scoreManager:getLevel())
            end
            
            if scoreManager:getTotalLines() ~= initialState.totalLines then
                return false, string.format("Total lines changed from %d to %d after round trip", 
                    initialState.totalLines, scoreManager:getTotalLines())
            end
            
            -- Verify playfield state
            if playfield.grid[19][5] ~= initialState.playfieldBlock1 then
                return false, "Playfield block 1 changed after round trip"
            end
            
            if playfield.grid[19][6] ~= initialState.playfieldBlock2 then
                return false, "Playfield block 2 changed after round trip"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_pause_round_trip)

-- Property-based test for game over condition
-- Feature: playdate-tetris, Property 5: Game over on blocked spawn
-- Validates: Requirements 1.5

local lqc = require("lib/lqc")
local game = require("game/init")
local pieces = require("pieces/init")

-- Property 5: Game over on blocked spawn
-- For any playfield state where the spawn location contains blocks, 
-- attempting to spawn a new piece should transition the game state to "gameover"
local prop_game_over = lqc.property("game over when spawn is blocked",
    lqc.forall(
        {lqc.generators.int(1, 100)}, -- Dummy generator
        function(dummy)
            -- Create game components
            local playfield = game.Playfield:new(10, 20)
            local factory = pieces.TetrominoFactory:new()
            local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
            
            -- Fill the playfield up to the spawn area
            -- We'll fill rows from bottom to top, leaving only the top row
            for y = 2, playfield.height do
                for x = 1, playfield.width do
                    playfield.grid[y][x] = "I" -- Fill with any piece type
                end
            end
            
            -- Fill the spawn row (y=1) to block spawning
            -- Spawn location is around x=3-6 (1-based: 4-7)
            for x = 1, playfield.width do
                playfield.grid[1][x] = "I"
            end
            
            -- Game should not be over yet
            if gameState:isGameOver() then
                return false, "Game over before attempting blocked spawn"
            end
            
            -- Try to spawn a new piece (this should trigger game over)
            local spawnSuccess = gameState:spawnPiece()
            
            -- Spawn should fail
            if spawnSuccess then
                return false, "Spawn succeeded when it should have been blocked"
            end
            
            -- Game state should now be "gameover"
            if not gameState:isGameOver() then
                return false, "Game state is not 'gameover' after blocked spawn"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_game_over)

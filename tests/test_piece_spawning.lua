-- Property-based test for piece spawning
-- Feature: vibetris, Property 1: Piece spawns at correct location on game start
-- Validates: Requirements 1.1

local lqc = require("lib/lqc")
local pieces = require("pieces/init")

-- Property 1: Piece spawns at correct location on game start
-- For any new game initialization, the first Tetromino should appear at the 
-- top center of the playfield (x=3 or x=4, y=0)
local prop_spawn_location = lqc.property("pieces spawn at correct location",
    lqc.forall(
        {lqc.generators.int(1, 100)}, -- Use a dummy generator since we test factory behavior
        function(dummy)
            -- Create a factory and get a piece
            local factory = pieces.TetrominoFactory:new()
            local piece = factory:getRandomPiece()
            
            -- Piece should spawn at top (y=0)
            if piece.y ~= 0 then
                return false, string.format("Piece spawned at y=%d, expected y=0", piece.y)
            end
            
            -- Piece should spawn at center (x=3 or x=4)
            if piece.x ~= 3 and piece.x ~= 4 then
                return false, string.format("Piece spawned at x=%d, expected x=3 or x=4", piece.x)
            end
            
            -- Piece should start at rotation 0
            if piece.rotation ~= 0 then
                return false, string.format("Piece spawned at rotation=%d, expected rotation=0", piece.rotation)
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_spawn_location)

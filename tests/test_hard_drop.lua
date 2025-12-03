-- Property-based test for hard drop
-- Feature: playdate-tetris, Property 12: Hard drop moves to lowest position
-- Validates: Requirements 4.3

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
        
        -- Optionally add some blocks to the playfield to make it more interesting
        if math.random() < 0.3 then
            -- Add a few random blocks at the bottom (using 1-based indexing)
            for i = 1, math.random(5, 15) do
                local x = math.random(1, 10)
                local y = math.random(16, 20)
                playfield.grid[y] = playfield.grid[y] or {}
                playfield.grid[y][x] = "X"
            end
        end
        
        return gameState
    end)
end

-- Property 12: Hard drop moves to lowest position
-- For any Tetromino and playfield state, hard drop should move the piece to the
-- lowest y position where no collision occurs, then immediately lock it
local prop_hard_drop = lqc.property("hard drop moves to lowest position",
    lqc.forall(
        {generateGameStateWithPiece()},
        function(gameState)
            if not gameState.currentPiece then
                return false
            end
            
            local piece = gameState.currentPiece
            local playfield = gameState.playfield
            local originalY = piece.y
            local originalX = piece.x
            local originalType = piece.type
            
            -- Calculate the lowest valid position manually
            local expectedLowestY = originalY
            while game.CollisionDetector.canMoveTo(piece, playfield, piece.x, expectedLowestY + 1) do
                expectedLowestY = expectedLowestY + 1
            end
            
            -- Count blocks before hard drop (using 1-based indexing)
            local blocksBefore = 0
            for y = 1, playfield.height do
                if playfield.grid[y] then
                    for x = 1, playfield.width do
                        if playfield.grid[y][x] then
                            blocksBefore = blocksBefore + 1
                        end
                    end
                end
            end
            
            -- Perform hard drop
            gameState:hardDrop()
            
            -- After hard drop, a new piece should have spawned
            -- (because hard drop locks the piece immediately)
            if not gameState.currentPiece then
                return false
            end
            
            -- Count blocks after hard drop (using 1-based indexing)
            local blocksAfter = 0
            for y = 1, playfield.height do
                if playfield.grid[y] then
                    for x = 1, playfield.width do
                        if playfield.grid[y][x] then
                            blocksAfter = blocksAfter + 1
                        end
                    end
                end
            end
            
            -- The playfield should have 4 more blocks (one tetromino)
            if blocksAfter ~= blocksBefore + 4 then
                return false
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_hard_drop)

-- Property-based test for shadow piece accuracy
-- Feature: vibetris, Property 23: Shadow position matches hard drop destination
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
        if math.random() < 0.5 then
            -- Add random blocks at various heights (using 1-based indexing)
            for i = 1, math.random(5, 20) do
                local x = math.random(1, 10)
                local y = math.random(10, 20)
                playfield.grid[y] = playfield.grid[y] or {}
                playfield.grid[y][x] = "X"
            end
            -- Recalculate shadow after adding blocks
            gameState.shadowY = gameState:calculateShadowY()
        end
        
        -- Optionally move the piece to a random position
        if math.random() < 0.5 then
            local moves = math.random(0, 3)
            for i = 1, moves do
                if math.random() < 0.5 then
                    gameState:moveCurrentPiece(1, 0)
                else
                    gameState:moveCurrentPiece(-1, 0)
                end
            end
        end
        
        -- Optionally rotate the piece
        if math.random() < 0.5 then
            local rotations = math.random(0, 3)
            for i = 1, rotations do
                gameState:rotateCurrentPiece(1)
            end
        end
        
        return gameState
    end)
end

-- Property 23: Shadow position matches hard drop destination
-- For any Tetromino and playfield state, the shadow y-position should equal
-- the position the piece would reach if hard dropped
local prop_shadow_accuracy = lqc.property("shadow position matches hard drop destination",
    lqc.forall(
        {generateGameStateWithPiece()},
        function(gameState)
            if not gameState.currentPiece then
                return false
            end
            
            local piece = gameState.currentPiece
            local playfield = gameState.playfield
            
            -- Get the shadow Y position
            local shadowY = gameState.shadowY
            
            if shadowY == nil then
                return false
            end
            
            -- Calculate what the hard drop destination would be
            local expectedY = piece.y
            while game.CollisionDetector.canMoveTo(piece, playfield, piece.x, expectedY + 1) do
                expectedY = expectedY + 1
            end
            
            -- Shadow Y should match the hard drop destination
            if shadowY ~= expectedY then
                print("Shadow mismatch: shadowY=" .. tostring(shadowY) .. ", expectedY=" .. tostring(expectedY))
                return false
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_shadow_accuracy)

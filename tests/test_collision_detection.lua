-- Property-based test for collision detection
-- Feature: vibetris, Property 10: Invalid movements are rejected
-- Validates: Requirements 3.3

local lqc = require("lib/lqc")
local pieces = require("pieces/init")
local game = require("game/init")

-- Custom generator for playfield states
local Generator = {}
Generator.__index = Generator

function Generator:new(generate_fn)
    local gen = {
        generate = generate_fn
    }
    setmetatable(gen, Generator)
    return gen
end

local function generatePlayfield()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        
        -- Randomly add some locked blocks to the playfield
        local numBlocks = math.random(0, 30)
        for i = 1, numBlocks do
            local x = math.random(1, 10)
            local y = math.random(1, 20)
            playfield.grid[y][x] = "I" -- Use any piece type
        end
        
        return playfield
    end)
end

-- Custom generator for piece positions
local function generatePiecePosition()
    return Generator:new(function()
        local pieceTypes = {"I", "O", "T", "S", "Z", "J", "L"}
        local pieceType = pieceTypes[math.random(1, #pieceTypes)]
        local x = math.random(-2, 12) -- Include out-of-bounds positions
        local y = math.random(-2, 22)
        local rotation = math.random(0, 3)
        
        return pieces.Tetromino:new(pieceType, x, y, rotation)
    end)
end

-- Property 10: Invalid movements are rejected
-- For any Tetromino and movement that would cause collision with playfield 
-- boundaries or locked blocks, the piece's position should remain unchanged
local prop_invalid_movements_rejected = lqc.property("invalid movements are rejected",
    lqc.forall(
        {generatePlayfield(), generatePiecePosition()},
        function(playfield, piece)
            local originalX = piece.x
            local originalY = piece.y
            local originalRotation = piece.rotation
            
            -- Test 1: Movements that go out of bounds should be rejected
            -- Try to move far left (out of bounds)
            local canMoveLeft = game.CollisionDetector.canMoveTo(piece, playfield, -5, piece.y)
            if canMoveLeft then
                return false, "Movement to x=-5 should be rejected (out of bounds)"
            end
            
            -- Try to move far right (out of bounds)
            local canMoveRight = game.CollisionDetector.canMoveTo(piece, playfield, 15, piece.y)
            if canMoveRight then
                return false, "Movement to x=15 should be rejected (out of bounds)"
            end
            
            -- Try to move below playfield
            local canMoveDown = game.CollisionDetector.canMoveTo(piece, playfield, piece.x, 25)
            if canMoveDown then
                return false, "Movement to y=25 should be rejected (out of bounds)"
            end
            
            -- Test 2: Check that collision detection properly validates current position
            local isValid = game.CollisionDetector.isValidPosition(piece, playfield)
            
            -- If position is invalid, verify it's either out of bounds or overlapping
            if not isValid then
                local blocks = piece:getBlocks()
                local hasOutOfBounds = false
                local hasOverlap = false
                
                for i = 1, #blocks do
                    local block = blocks[i]
                    -- Check boundaries
                    if block.x < 0 or block.x >= playfield.width or 
                       block.y < 0 or block.y >= playfield.height then
                        hasOutOfBounds = true
                    end
                    
                    -- Check overlap (convert to 1-based)
                    if block.x >= 0 and block.x < playfield.width and
                       block.y >= 0 and block.y < playfield.height then
                        local gridX = block.x + 1
                        local gridY = block.y + 1
                        if playfield:isOccupied(gridX, gridY) then
                            hasOverlap = true
                        end
                    end
                end
                
                if not hasOutOfBounds and not hasOverlap then
                    return false, "Position marked invalid but no collision detected"
                end
            end
            
            -- Test 3: Verify that piece state hasn't changed during validation
            if piece.x ~= originalX or piece.y ~= originalY or piece.rotation ~= originalRotation then
                return false, "Collision detection modified piece state"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_invalid_movements_rejected)


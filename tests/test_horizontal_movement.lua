-- Property-based test for horizontal movement
-- Feature: vibetris, Property 9: Horizontal movement changes position
-- Validates: Requirements 3.1, 3.2

local lqc = require("lib/lqc")
local pieces = require("pieces/init")
local game = require("game/init")

-- Custom generator for valid piece positions
local Generator = {}
Generator.__index = Generator

function Generator:new(generate_fn)
    local gen = {
        generate = generate_fn
    }
    setmetatable(gen, Generator)
    return gen
end

local function generateValidPieceInPlayfield()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        local pieceTypes = {"I", "O", "T", "S", "Z", "J", "L"}
        local pieceType = pieceTypes[math.random(1, #pieceTypes)]
        
        -- Generate piece in valid position (center of playfield)
        local x = math.random(2, 6)
        local y = math.random(2, 10)
        local rotation = math.random(0, 3)
        
        local piece = pieces.Tetromino:new(pieceType, x, y, rotation)
        
        -- Ensure the piece is in a valid position
        if not game.CollisionDetector.isValidPosition(piece, playfield) then
            -- Try a safer position
            piece.x = 4
            piece.y = 5
            piece.rotation = 0
        end
        
        return {piece = piece, playfield = playfield}
    end)
end

-- Property 9: Horizontal movement changes position
-- For any Tetromino and valid horizontal direction (left or right), 
-- the piece's x position should change by ±1 column
local prop_horizontal_movement = lqc.property("horizontal movement changes position",
    lqc.forall(
        {generateValidPieceInPlayfield()},
        function(data)
            local piece = data.piece
            local playfield = data.playfield
            
            local originalX = piece.x
            local originalY = piece.y
            
            -- Test left movement
            local canMoveLeft = game.CollisionDetector.canMoveTo(piece, playfield, originalX - 1, originalY)
            if canMoveLeft then
                local moved = piece:move(-1, 0, playfield, game.CollisionDetector)
                if not moved then
                    return false, "Move left should succeed when canMoveTo returns true"
                end
                if piece.x ~= originalX - 1 then
                    return false, "Left movement should decrease x by 1"
                end
                if piece.y ~= originalY then
                    return false, "Horizontal movement should not change y position"
                end
                -- Reset position
                piece.x = originalX
            end
            
            -- Test right movement
            local canMoveRight = game.CollisionDetector.canMoveTo(piece, playfield, originalX + 1, originalY)
            if canMoveRight then
                local moved = piece:move(1, 0, playfield, game.CollisionDetector)
                if not moved then
                    return false, "Move right should succeed when canMoveTo returns true"
                end
                if piece.x ~= originalX + 1 then
                    return false, "Right movement should increase x by 1"
                end
                if piece.y ~= originalY then
                    return false, "Horizontal movement should not change y position"
                end
                -- Reset position
                piece.x = originalX
            end
            
            -- Test that invalid movements are rejected
            -- Try to move far left (should fail)
            local originalXBeforeInvalid = piece.x
            local movedInvalid = piece:move(-20, 0, playfield, game.CollisionDetector)
            if movedInvalid then
                return false, "Invalid left movement should be rejected"
            end
            if piece.x ~= originalXBeforeInvalid then
                return false, "Failed movement should not change position"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_horizontal_movement)

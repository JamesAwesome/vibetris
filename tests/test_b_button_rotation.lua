-- Property-based test for B button rotation
-- Feature: vibetris, Property 22: B button rotation changes piece orientation
-- Validates: Requirements 2.3

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
        
        -- Generate piece in valid position (center of playfield with room to rotate)
        local x = 4
        local y = 5
        local rotation = math.random(0, 3)
        
        local piece = pieces.Tetromino:new(pieceType, x, y, rotation)
        
        return {piece = piece, playfield = playfield}
    end)
end

-- Property 22: B button rotation changes piece orientation
-- For any Tetromino, pressing the B button should rotate the piece 90 degrees clockwise when rotation is valid
local prop_b_button_rotation = lqc.property("B button rotation changes piece orientation",
    lqc.forall(
        {generateValidPieceInPlayfield()},
        function(data)
            local piece = data.piece
            local playfield = data.playfield
            
            local originalRotation = piece.rotation
            local originalX = piece.x
            local originalY = piece.y
            
            -- Test clockwise rotation (B button always rotates clockwise)
            local expectedRotation = (originalRotation + 1) % 4
            local canRotate = game.CollisionDetector.canRotate(piece, playfield, expectedRotation)
            
            if canRotate then
                -- Simulate B button rotation (direction = 1 for clockwise)
                local rotated = piece:rotate(1, playfield, game.CollisionDetector)
                
                if not rotated then
                    return false, "B button rotation should succeed when canRotate returns true"
                end
                
                if piece.rotation ~= expectedRotation then
                    return false, string.format("B button rotation should change rotation from %d to %d, got %d", 
                        originalRotation, expectedRotation, piece.rotation)
                end
                
                -- Position may change due to wall kicks, but that's ok
                -- The important thing is that rotation state changed
            end
            
            -- Reset piece
            piece.rotation = originalRotation
            piece.x = originalX
            piece.y = originalY
            
            -- Test that rotation without validation always succeeds
            local testPiece = pieces.Tetromino:new(piece.type, 4, 5, 0)
            testPiece:rotate(1) -- Should always succeed without validation
            if testPiece.rotation ~= 1 then
                return false, "B button rotation without validation should always succeed"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_b_button_rotation)

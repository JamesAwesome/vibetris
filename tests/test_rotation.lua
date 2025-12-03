-- Property-based test for rotation
-- Feature: playdate-tetris, Property 6: Crank rotation changes piece orientation
-- Validates: Requirements 2.1, 2.2

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

-- Property 6: Crank rotation changes piece orientation
-- For any Tetromino and crank rotation direction (clockwise or counter-clockwise), 
-- the piece's rotation state should change by ±90 degrees when rotation is valid
local prop_rotation_changes_orientation = lqc.property("crank rotation changes piece orientation",
    lqc.forall(
        {generateValidPieceInPlayfield()},
        function(data)
            local piece = data.piece
            local playfield = data.playfield
            
            local originalRotation = piece.rotation
            local originalX = piece.x
            local originalY = piece.y
            
            -- Test clockwise rotation (direction = 1)
            local expectedClockwise = (originalRotation + 1) % 4
            local canRotateClockwise = game.CollisionDetector.canRotate(piece, playfield, expectedClockwise)
            
            if canRotateClockwise then
                local rotated = piece:rotate(1, playfield, game.CollisionDetector)
                if not rotated then
                    return false, "Clockwise rotation should succeed when canRotate returns true"
                end
                if piece.rotation ~= expectedClockwise then
                    return false, string.format("Clockwise rotation should change rotation from %d to %d, got %d", 
                        originalRotation, expectedClockwise, piece.rotation)
                end
                -- Position may change due to wall kicks, but that's ok
                
                -- Reset for next test
                piece.rotation = originalRotation
                piece.x = originalX
                piece.y = originalY
            end
            
            -- Test counter-clockwise rotation (direction = -1)
            local expectedCounterClockwise = (originalRotation - 1) % 4
            local canRotateCounterClockwise = game.CollisionDetector.canRotate(piece, playfield, expectedCounterClockwise)
            
            if canRotateCounterClockwise then
                local rotated = piece:rotate(-1, playfield, game.CollisionDetector)
                if not rotated then
                    return false, "Counter-clockwise rotation should succeed when canRotate returns true"
                end
                if piece.rotation ~= expectedCounterClockwise then
                    return false, string.format("Counter-clockwise rotation should change rotation from %d to %d, got %d", 
                        originalRotation, expectedCounterClockwise, piece.rotation)
                end
                
                -- Reset
                piece.rotation = originalRotation
                piece.x = originalX
                piece.y = originalY
            end
            
            -- Test rotation without validation (no playfield/collision detector)
            local testPiece = pieces.Tetromino:new(piece.type, 4, 5, 0)
            testPiece:rotate(1) -- Should always succeed without validation
            if testPiece.rotation ~= 1 then
                return false, "Rotation without validation should always succeed"
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_rotation_changes_orientation)

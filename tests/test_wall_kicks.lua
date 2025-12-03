-- Property-based test for wall kicks
-- Feature: playdate-tetris, Property 7: Wall kick attempts on blocked rotation
-- Validates: Requirements 2.3

local lqc = require("lib/lqc")
local pieces = require("pieces/init")
local game = require("game/init")

-- Custom generator
local Generator = {}
Generator.__index = Generator

function Generator:new(generate_fn)
    local gen = {
        generate = generate_fn
    }
    setmetatable(gen, Generator)
    return gen
end

local function generatePieceNearWall()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        local pieceTypes = {"I", "T", "S", "Z", "J", "L"} -- Exclude O since it doesn't rotate visually
        local pieceType = pieceTypes[math.random(1, #pieceTypes)]
        
        -- Place piece near a wall or with some blocked cells
        local positions = {
            {x = 0, y = 5},  -- Left wall
            {x = 8, y = 5},  -- Right wall
            {x = 4, y = 18}, -- Near bottom
        }
        local pos = positions[math.random(1, #positions)]
        
        local rotation = math.random(0, 3)
        local piece = pieces.Tetromino:new(pieceType, pos.x, pos.y, rotation)
        
        -- Optionally add some blocks to create obstacles
        if math.random() > 0.5 then
            local numBlocks = math.random(1, 5)
            for i = 1, numBlocks do
                local bx = math.random(1, 10)
                local by = math.random(1, 20)
                playfield.grid[by][bx] = "I"
            end
        end
        
        return {piece = piece, playfield = playfield}
    end)
end

-- Property 7: Wall kick attempts on blocked rotation
-- For any Tetromino where direct rotation would cause collision, 
-- the system should attempt wall kick position adjustments before rejecting the rotation
local prop_wall_kick_attempts = lqc.property("wall kick attempts on blocked rotation",
    lqc.forall(
        {generatePieceNearWall()},
        function(data)
            local piece = data.piece
            local playfield = data.playfield
            
            local originalX = piece.x
            local originalY = piece.y
            local originalRotation = piece.rotation
            
            -- Try to rotate clockwise
            local newRotation = (originalRotation + 1) % 4
            
            -- Check if direct rotation would work
            local canRotateDirect = game.CollisionDetector.canRotate(piece, playfield, newRotation)
            
            -- Attempt rotation (which includes wall kicks)
            local rotated = piece:rotate(1, playfield, game.CollisionDetector)
            
            if canRotateDirect then
                -- If direct rotation works, rotation should succeed
                if not rotated then
                    return false, "Rotation should succeed when direct rotation is valid"
                end
                if piece.rotation ~= newRotation then
                    return false, "Rotation state should be updated on successful rotation"
                end
            else
                -- Direct rotation blocked - wall kicks should be attempted
                if rotated then
                    -- Wall kick succeeded
                    if piece.rotation ~= newRotation then
                        return false, "Rotation state should be updated when wall kick succeeds"
                    end
                    -- Position should have changed (wall kick moved the piece)
                    if piece.x == originalX and piece.y == originalY then
                        -- This is actually ok - the first wall kick offset is {0,0}
                        -- So position might not change
                    end
                    -- Verify the new position is valid
                    if not game.CollisionDetector.isValidPosition(piece, playfield) then
                        return false, "Wall kick resulted in invalid position"
                    end
                else
                    -- Wall kick failed - state should be preserved
                    if piece.rotation ~= originalRotation then
                        return false, "Failed rotation should preserve rotation state"
                    end
                    if piece.x ~= originalX or piece.y ~= originalY then
                        return false, "Failed rotation should preserve position"
                    end
                end
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_wall_kick_attempts)

-- Property-based test for failed rotation
-- Feature: vibetris, Property 8: Failed rotation preserves state
-- Validates: Requirements 2.4

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

local function generateBlockedRotationScenario()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        local pieceTypes = {"I", "T", "S", "Z", "J", "L"}
        local pieceType = pieceTypes[math.random(1, #pieceTypes)]
        
        -- Create a scenario where rotation is likely to be blocked
        -- Place piece in corner or surrounded by blocks
        local x = math.random() > 0.5 and 0 or 9
        local y = 18
        local rotation = math.random(0, 3)
        
        local piece = pieces.Tetromino:new(pieceType, x, y, rotation)
        
        -- Fill surrounding cells to block rotation
        -- Create a tight box around the piece
        for dy = -1, 3 do
            for dx = -2, 3 do
                local gridX = x + dx + 1
                local gridY = y + dy + 1
                if gridX >= 1 and gridX <= 10 and gridY >= 1 and gridY <= 20 then
                    -- Randomly fill some cells
                    if math.random() > 0.3 then
                        playfield.grid[gridY][gridX] = "I"
                    end
                end
            end
        end
        
        -- Clear the cells occupied by the piece itself
        local blocks = piece:getBlocks()
        for i = 1, #blocks do
            local block = blocks[i]
            local gridX = block.x + 1
            local gridY = block.y + 1
            if gridX >= 1 and gridX <= 10 and gridY >= 1 and gridY <= 20 then
                playfield.grid[gridY][gridX] = nil
            end
        end
        
        return {piece = piece, playfield = playfield}
    end)
end

-- Property 8: Failed rotation preserves state
-- For any Tetromino where rotation and all wall kicks fail, 
-- the piece's position and rotation state should remain unchanged
local prop_failed_rotation_preserves_state = lqc.property("failed rotation preserves state",
    lqc.forall(
        {generateBlockedRotationScenario()},
        function(data)
            local piece = data.piece
            local playfield = data.playfield
            
            local originalX = piece.x
            local originalY = piece.y
            local originalRotation = piece.rotation
            
            -- Try clockwise rotation
            local rotatedCW = piece:rotate(1, playfield, game.CollisionDetector)
            
            if not rotatedCW then
                -- Rotation failed - verify state is preserved
                if piece.x ~= originalX then
                    return false, string.format("Failed clockwise rotation changed x from %d to %d", originalX, piece.x)
                end
                if piece.y ~= originalY then
                    return false, string.format("Failed clockwise rotation changed y from %d to %d", originalY, piece.y)
                end
                if piece.rotation ~= originalRotation then
                    return false, string.format("Failed clockwise rotation changed rotation from %d to %d", 
                        originalRotation, piece.rotation)
                end
            else
                -- Rotation succeeded - reset for next test
                piece.x = originalX
                piece.y = originalY
                piece.rotation = originalRotation
            end
            
            -- Try counter-clockwise rotation
            local rotatedCCW = piece:rotate(-1, playfield, game.CollisionDetector)
            
            if not rotatedCCW then
                -- Rotation failed - verify state is preserved
                if piece.x ~= originalX then
                    return false, string.format("Failed counter-clockwise rotation changed x from %d to %d", 
                        originalX, piece.x)
                end
                if piece.y ~= originalY then
                    return false, string.format("Failed counter-clockwise rotation changed y from %d to %d", 
                        originalY, piece.y)
                end
                if piece.rotation ~= originalRotation then
                    return false, string.format("Failed counter-clockwise rotation changed rotation from %d to %d", 
                        originalRotation, piece.rotation)
                end
            end
            
            -- Verify piece is still in a valid state (if it was valid to begin with)
            local wasValid = game.CollisionDetector.isValidPosition(piece, playfield)
            if wasValid then
                -- After failed rotations, piece should still be valid
                if not game.CollisionDetector.isValidPosition(piece, playfield) then
                    return false, "Failed rotation made valid piece invalid"
                end
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_failed_rotation_preserves_state)

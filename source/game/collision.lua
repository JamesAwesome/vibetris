-- Collision detection module
-- Handles collision checking between Tetrominos and the playfield

local CollisionDetector = {}

function CollisionDetector.canMoveTo(piece, playfield, x, y)
    -- Check if a piece can move to the specified position
    -- Create a temporary piece at the new position
    local tempPiece = {
        type = piece.type,
        x = x,
        y = y,
        rotation = piece.rotation,
        shapes = piece.shapes,
        getBlocks = piece.getBlocks
    }
    setmetatable(tempPiece, getmetatable(piece))
    
    return CollisionDetector.isValidPosition(tempPiece, playfield)
end

function CollisionDetector.canRotate(piece, playfield, rotation)
    -- Check if a piece can rotate to the specified rotation state
    -- Create a temporary piece with the new rotation
    local tempPiece = {
        type = piece.type,
        x = piece.x,
        y = piece.y,
        rotation = rotation,
        shapes = piece.shapes,
        getBlocks = piece.getBlocks
    }
    setmetatable(tempPiece, getmetatable(piece))
    
    return CollisionDetector.isValidPosition(tempPiece, playfield)
end

function CollisionDetector.isValidPosition(piece, playfield)
    -- Check if a piece's current position is valid
    -- (within bounds and not overlapping locked blocks)
    local blocks = piece:getBlocks()
    
    for i = 1, #blocks do
        local block = blocks[i]
        
        -- Check boundaries (0-based coordinates)
        if block.x < 0 or block.x >= playfield.width then
            return false
        end
        if block.y < 0 or block.y >= playfield.height then
            return false
        end
        
        -- Check for overlap with locked blocks (convert to 1-based for grid)
        local gridX = block.x + 1
        local gridY = block.y + 1
        if playfield:isOccupied(gridX, gridY) then
            return false
        end
    end
    
    return true
end

-- Export module
return CollisionDetector


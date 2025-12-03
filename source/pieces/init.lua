-- Pieces module: Tetromino definitions and factory
-- Defines the 7 standard Tetromino types with all 4 rotation states

-- Tetromino shape definitions
-- Each shape has 4 rotation states (0, 1, 2, 3) representing 0°, 90°, 180°, 270°
-- Each rotation state contains 4 block positions as {x, y} offsets from origin
local SHAPES = {
    I = {
        [0] = {{0,1}, {1,1}, {2,1}, {3,1}},
        [1] = {{2,0}, {2,1}, {2,2}, {2,3}},
        [2] = {{0,2}, {1,2}, {2,2}, {3,2}},
        [3] = {{1,0}, {1,1}, {1,2}, {1,3}},
    },
    O = {
        [0] = {{1,0}, {2,0}, {1,1}, {2,1}},
        [1] = {{1,0}, {2,0}, {1,1}, {2,1}},
        [2] = {{1,0}, {2,0}, {1,1}, {2,1}},
        [3] = {{1,0}, {2,0}, {1,1}, {2,1}},
    },
    T = {
        [0] = {{1,0}, {0,1}, {1,1}, {2,1}},
        [1] = {{1,0}, {1,1}, {2,1}, {1,2}},
        [2] = {{0,1}, {1,1}, {2,1}, {1,2}},
        [3] = {{1,0}, {0,1}, {1,1}, {1,2}},
    },
    S = {
        [0] = {{1,0}, {2,0}, {0,1}, {1,1}},
        [1] = {{1,0}, {1,1}, {2,1}, {2,2}},
        [2] = {{1,1}, {2,1}, {0,2}, {1,2}},
        [3] = {{0,0}, {0,1}, {1,1}, {1,2}},
    },
    Z = {
        [0] = {{0,0}, {1,0}, {1,1}, {2,1}},
        [1] = {{2,0}, {1,1}, {2,1}, {1,2}},
        [2] = {{0,1}, {1,1}, {1,2}, {2,2}},
        [3] = {{1,0}, {0,1}, {1,1}, {0,2}},
    },
    J = {
        [0] = {{0,0}, {0,1}, {1,1}, {2,1}},
        [1] = {{1,0}, {2,0}, {1,1}, {1,2}},
        [2] = {{0,1}, {1,1}, {2,1}, {2,2}},
        [3] = {{1,0}, {1,1}, {0,2}, {1,2}},
    },
    L = {
        [0] = {{2,0}, {0,1}, {1,1}, {2,1}},
        [1] = {{1,0}, {1,1}, {1,2}, {2,2}},
        [2] = {{0,1}, {1,1}, {2,1}, {0,2}},
        [3] = {{0,0}, {1,0}, {1,1}, {1,2}},
    },
}

-- Tetromino class
local Tetromino = {}
Tetromino.__index = Tetromino

function Tetromino:new(type, x, y, rotation)
    local self = setmetatable({}, Tetromino)
    self.type = type
    self.x = x or 0
    self.y = y or 0
    self.rotation = rotation or 0
    self.shapes = SHAPES[type]
    return self
end

function Tetromino:getBlocks()
    -- Returns the absolute positions of all 4 blocks
    local blocks = {}
    local shapeBlocks = self.shapes[self.rotation]
    for i = 1, #shapeBlocks do
        local offset = shapeBlocks[i]
        table.insert(blocks, {x = self.x + offset[1], y = self.y + offset[2]})
    end
    return blocks
end

function Tetromino:rotate(direction, playfield, collisionDetector)
    -- Rotate the piece: direction = 1 for clockwise, -1 for counter-clockwise
    -- Returns true if rotation succeeded, false otherwise
    if not playfield or not collisionDetector then
        -- No validation, just rotate
        local newRotation = (self.rotation + direction) % 4
        self.rotation = newRotation
        return true
    end
    
    local newRotation = (self.rotation + direction) % 4
    
    -- Try direct rotation first
    if collisionDetector.canRotate(self, playfield, newRotation) then
        self.rotation = newRotation
        return true
    end
    
    -- Try wall kicks
    local kicked = self:tryWallKick(newRotation, playfield, collisionDetector)
    if kicked then
        self.rotation = newRotation
        return true
    end
    
    -- Rotation failed, state preserved
    return false
end

function Tetromino:tryWallKick(newRotation, playfield, collisionDetector)
    -- Attempt wall kick adjustments when rotation is blocked
    -- Returns true if a valid wall kick position was found, false otherwise
    
    -- Wall kick offsets to try (standard Tetris wall kick system)
    -- Try moving left, right, up, and combinations
    local wallKickOffsets = {
        {0, 0},   -- No offset (already tried in rotate)
        {-1, 0},  -- Left 1
        {1, 0},   -- Right 1
        {0, -1},  -- Up 1
        {-1, -1}, -- Left 1, Up 1
        {1, -1},  -- Right 1, Up 1
        {-2, 0},  -- Left 2
        {2, 0},   -- Right 2
    }
    
    -- Save original position
    local originalX = self.x
    local originalY = self.y
    local originalRotation = self.rotation
    
    -- Try each wall kick offset
    for i = 1, #wallKickOffsets do
        local offset = wallKickOffsets[i]
        local testX = originalX + offset[1]
        local testY = originalY + offset[2]
        
        -- Temporarily set new rotation to test position
        self.rotation = newRotation
        
        if collisionDetector.canMoveTo(self, playfield, testX, testY) then
            -- Found valid position, apply it
            self.x = testX
            self.y = testY
            -- Keep new rotation
            return true
        end
    end
    
    -- Restore original state
    self.rotation = originalRotation
    return false
end

function Tetromino:move(dx, dy, playfield, collisionDetector)
    -- Move the piece by the given offset
    -- Returns true if move succeeded, false otherwise
    if not playfield or not collisionDetector then
        -- No validation, just move
        self.x = self.x + dx
        self.y = self.y + dy
        return true
    end
    
    local newX = self.x + dx
    local newY = self.y + dy
    
    if collisionDetector.canMoveTo(self, playfield, newX, newY) then
        self.x = newX
        self.y = newY
        return true
    end
    
    -- Move failed, position unchanged
    return false
end

-- TetrominoFactory class
local TetrominoFactory = {}
TetrominoFactory.__index = TetrominoFactory

function TetrominoFactory:new()
    local self = setmetatable({}, TetrominoFactory)
    self.pieceTypes = {"I", "O", "T", "S", "Z", "J", "L"}
    self.nextPiece = nil
    self:generateNext()
    return self
end

function TetrominoFactory:generateNext()
    -- Generate a random piece type
    local randomIndex = math.random(1, #self.pieceTypes)
    local pieceType = self.pieceTypes[randomIndex]
    self.nextPiece = pieceType
end

function TetrominoFactory:getRandomPiece()
    -- Return the next piece and generate a new one
    local pieceType = self.nextPiece
    self:generateNext()
    
    -- Spawn at top center of playfield (x=3 for most pieces, x=4 for I piece)
    local spawnX = (pieceType == "I") and 3 or 3
    local spawnY = 0
    
    return Tetromino:new(pieceType, spawnX, spawnY, 0)
end

function TetrominoFactory:peekNext()
    -- Return the next piece type without consuming it
    return self.nextPiece
end

-- Export module (make globally available for Playdate import system)
_G.Tetromino = Tetromino
_G.TetrominoFactory = TetrominoFactory
_G.SHAPES = SHAPES

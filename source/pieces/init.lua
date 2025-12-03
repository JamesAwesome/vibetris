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

function Tetromino:rotate(direction)
    -- Rotate the piece: direction = 1 for clockwise, -1 for counter-clockwise
    local newRotation = (self.rotation + direction) % 4
    self.rotation = newRotation
end

function Tetromino:move(dx, dy)
    -- Move the piece by the given offset
    self.x = self.x + dx
    self.y = self.y + dy
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

-- Export module
return {
    Tetromino = Tetromino,
    TetrominoFactory = TetrominoFactory,
    SHAPES = SHAPES,
}

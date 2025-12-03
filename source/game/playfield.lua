-- Playfield module: Manages the 10x20 game grid
-- Handles locked block positions, line detection, and clearing

local Playfield = {}
Playfield.__index = Playfield

function Playfield:new(width, height)
    local self = setmetatable({}, Playfield)
    self.width = width or 10
    self.height = height or 20
    self.grid = {}
    
    -- Initialize empty grid
    for y = 1, self.height do
        self.grid[y] = {}
        for x = 1, self.width do
            self.grid[y][x] = nil
        end
    end
    
    return self
end

function Playfield:isOccupied(x, y)
    -- Check if a position is occupied by a locked block
    -- Returns true if occupied, false if empty or out of bounds
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false -- Out of bounds positions are not "occupied" in the grid
    end
    return self.grid[y][x] ~= nil
end

function Playfield:lockPiece(piece)
    -- Lock a piece into the playfield grid
    local blocks = piece:getBlocks()
    for i = 1, #blocks do
        local block = blocks[i]
        -- Convert from 0-based to 1-based indexing
        local gridX = block.x + 1
        local gridY = block.y + 1
        
        if gridX >= 1 and gridX <= self.width and gridY >= 1 and gridY <= self.height then
            self.grid[gridY][gridX] = piece.type
        end
    end
end

function Playfield:checkLines()
    -- Check for completed lines and return their indices
    local completedLines = {}
    
    for y = 1, self.height do
        local isComplete = true
        for x = 1, self.width do
            if self.grid[y][x] == nil then
                isComplete = false
                break
            end
        end
        if isComplete then
            table.insert(completedLines, y)
        end
    end
    
    return completedLines
end

function Playfield:clearLines(lines)
    -- Clear the specified lines and collapse rows above
    if #lines == 0 then
        return
    end
    
    -- Sort lines in descending order to clear from bottom to top
    table.sort(lines, function(a, b) return a > b end)
    
    -- Remove each line
    for i = 1, #lines do
        local lineY = lines[i]
        table.remove(self.grid, lineY)
    end
    
    -- Add new empty lines at the top
    for i = 1, #lines do
        local newLine = {}
        for x = 1, self.width do
            newLine[x] = nil
        end
        table.insert(self.grid, 1, newLine)
    end
end

function Playfield:clear()
    -- Clear the entire playfield (reset to empty state)
    for y = 1, self.height do
        for x = 1, self.width do
            self.grid[y][x] = nil
        end
    end
end

-- Export module (make globally available for Playdate import system)
_G.Playfield = Playfield


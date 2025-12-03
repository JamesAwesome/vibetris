-- Game state module: Manages game state including falling and locking
-- Handles automatic descent, lock delay, and piece spawning

local GameState = {}
GameState.__index = GameState

function GameState:new(playfield, factory, collisionDetector)
    local self = setmetatable({}, GameState)
    self.playfield = playfield
    self.factory = factory
    self.collisionDetector = collisionDetector
    
    -- Game state
    self.currentPiece = nil
    self.nextPiece = nil
    self.state = "playing" -- "playing", "paused", "gameover"
    
    -- Timing
    self.fallTimer = 0
    self.fallInterval = 1.0 -- 1 second per row at level 1
    self.lockTimer = 0
    self.lockDelay = 0.5 -- 0.5 seconds lock delay
    self.isLocking = false
    
    -- Initialize first pieces
    self:spawnPiece()
    
    return self
end

function GameState:spawnPiece()
    -- Spawn a new piece at the top of the playfield
    -- Returns true if spawn succeeded, false if blocked (game over)
    
    self.currentPiece = self.factory:getRandomPiece()
    self.nextPiece = self.factory:peekNext()
    
    -- Check if spawn position is valid
    if not self.collisionDetector.isValidPosition(self.currentPiece, self.playfield) then
        -- Spawn blocked - game over
        self.state = "gameover"
        return false
    end
    
    -- Reset lock state
    self.isLocking = false
    self.lockTimer = 0
    
    return true
end

function GameState:update(dt)
    -- Update game state with delta time
    if self.state ~= "playing" then
        return
    end
    
    if not self.currentPiece then
        return
    end
    
    local remainingTime = dt
    local iterations = 0
    local maxIterations = 10
    
    -- Process time in chunks to handle fall and lock correctly
    while remainingTime > 0 and iterations < maxIterations do
        iterations = iterations + 1
        
        if self.isLocking then
            -- Update lock timer
            local timeToLock = self.lockDelay - self.lockTimer
            local timeUsed = math.min(remainingTime, timeToLock)
            self.lockTimer = self.lockTimer + timeUsed
            remainingTime = remainingTime - timeUsed
            
            if self.lockTimer >= self.lockDelay then
                self:lockCurrentPiece()
                -- Continue processing remaining time with new piece
            else
                -- Not enough time to lock, exit loop
                break
            end
        else
            -- Update fall timer
            local timeToFall = self.fallInterval - self.fallTimer
            local timeUsed = math.min(remainingTime, timeToFall)
            self.fallTimer = self.fallTimer + timeUsed
            remainingTime = remainingTime - timeUsed
            
            if self.fallTimer >= self.fallInterval then
                self.fallTimer = 0
                self:applyGravity()
                -- Continue processing remaining time (might start locking)
            else
                -- Not enough time to fall, exit loop
                break
            end
        end
    end
end

function GameState:applyGravity()
    -- Move piece down by one row
    if not self.currentPiece then
        return
    end
    
    local canMoveDown = self.currentPiece:move(0, 1, self.playfield, self.collisionDetector)
    
    if not canMoveDown then
        -- Piece can't move down - start lock delay
        if not self.isLocking then
            self.isLocking = true
            self.lockTimer = 0
        end
    else
        -- Piece moved down successfully - reset lock state
        self.isLocking = false
        self.lockTimer = 0
    end
end

function GameState:lockCurrentPiece()
    -- Lock the current piece to the playfield and spawn a new one
    if not self.currentPiece then
        return
    end
    
    -- Lock piece to playfield
    self.playfield:lockPiece(self.currentPiece)
    
    -- Reset lock state
    self.isLocking = false
    self.lockTimer = 0
    
    -- Spawn new piece
    self:spawnPiece()
end

function GameState:canMoveDown()
    -- Check if current piece can move down
    if not self.currentPiece then
        return false
    end
    
    return self.collisionDetector.canMoveTo(
        self.currentPiece, 
        self.playfield, 
        self.currentPiece.x, 
        self.currentPiece.y + 1
    )
end

function GameState:pause()
    -- Pause the game
    if self.state == "playing" then
        self.state = "paused"
    end
end

function GameState:unpause()
    -- Resume the game
    if self.state == "paused" then
        self.state = "playing"
    end
end

function GameState:isGameOver()
    return self.state == "gameover"
end

function GameState:setSoftDrop(active)
    -- Enable or disable soft drop (faster falling)
    if active then
        -- Soft drop: 15x faster falling (tuned for better control)
        if not self.baseFallInterval then
            self.baseFallInterval = self.fallInterval
            self.fallInterval = self.fallInterval / 15
        end
    else
        -- Restore normal fall speed
        if self.baseFallInterval then
            self.fallInterval = self.baseFallInterval
            self.baseFallInterval = nil
        end
    end
end

function GameState:hardDrop()
    -- Instantly drop the piece to the lowest valid position and lock it
    if not self.currentPiece then
        return
    end
    
    -- Find the lowest valid position
    local lowestY = self.currentPiece.y
    while self.collisionDetector.canMoveTo(self.currentPiece, self.playfield, self.currentPiece.x, lowestY + 1) do
        lowestY = lowestY + 1
    end
    
    -- Move piece to lowest position
    self.currentPiece.y = lowestY
    
    -- Lock immediately
    self:lockCurrentPiece()
end

function GameState:moveCurrentPiece(dx, dy)
    -- Move the current piece by the given offset
    -- Returns true if move succeeded, false otherwise
    if not self.currentPiece then
        return false
    end
    
    return self.currentPiece:move(dx, dy, self.playfield, self.collisionDetector)
end

function GameState:rotateCurrentPiece(direction)
    -- Rotate the current piece
    -- Returns true if rotation succeeded, false otherwise
    if not self.currentPiece then
        return false
    end
    
    return self.currentPiece:rotate(direction, self.playfield, self.collisionDetector)
end

-- Export module (make globally available for Playdate import system)
_G.GameState = GameState

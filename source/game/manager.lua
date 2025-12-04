-- GameManager: Coordinates overall game flow and state transitions
-- Manages game state machine (menu, playing, paused, gameover)
-- Wires together all game components

local GameManager = {}
GameManager.__index = GameManager

function GameManager:new(playfield, factory, collisionDetector, scoreManager, inputHandler, gameState, startScreen)
    local self = setmetatable({}, GameManager)
    
    -- Core components
    self.playfield = playfield
    self.factory = factory
    self.collisionDetector = collisionDetector
    self.scoreManager = scoreManager
    self.inputHandler = inputHandler
    self.gameState = gameState
    self.startScreen = startScreen
    
    -- State machine: "start_screen", "menu", "playing", "paused", "gameover"
    self.state = "start_screen"
    
    -- Show start screen on initialization
    if self.startScreen then
        self.startScreen:show()
    end
    
    -- Menu scroll state
    self.menuScrollOffset = 0
    
    -- Settings
    self.showFPS = false  -- FPS counter hidden by default
    
    -- Line clear animation state
    self.clearingLines = nil -- Array of line indices being cleared
    self.clearAnimationTimer = 0
    self.clearAnimationDuration = 0.25 -- 250ms animation (tuned for snappier feel)
    
    return self
end

function GameManager:init()
    -- Initialize the game (called when starting a new game)
    self.state = "playing"
    
    -- Reset score manager
    self.scoreManager = ScoreManager:new()
    
    -- Reset playfield
    self.playfield:clear()
    
    -- Reset game state with new pieces
    self.gameState = GameState:new(
        self.playfield, 
        self.factory, 
        self.collisionDetector
    )
    
    -- Update fall speed based on level
    self.gameState.fallInterval = self.scoreManager:getFallSpeed()
    
    -- Reset animation state
    self.clearingLines = nil
    self.clearAnimationTimer = 0
end

function GameManager:update(dt)
    -- Main update loop
    
    if self.state == "start_screen" then
        self:updateStartScreen(dt)
    elseif self.state == "menu" then
        self:updateMenu(dt)
    elseif self.state == "playing" then
        self:updatePlaying(dt)
    elseif self.state == "paused" then
        self:updatePaused(dt)
    elseif self.state == "gameover" then
        self:updateGameOver(dt)
    end
end

function GameManager:updateStartScreen(dt)
    -- Handle start screen state
    if self.startScreen then
        local shouldTransition = self.startScreen:update(dt)
        if shouldTransition then
            self:changeState("menu")
        end
    else
        -- No start screen, go directly to menu
        self:changeState("menu")
    end
end

function GameManager:updateMenu(dt)
    -- Handle menu state
    -- Check for start game input
    if self.inputHandler then
        self.inputHandler:update(dt)
        
        -- Handle crank scrolling (clockwise = scroll down, counter-clockwise = scroll up)
        local crankChange = playdate.getCrankChange()
        if crankChange ~= 0 then
            self.menuScrollOffset = self.menuScrollOffset + crankChange
            -- Clamp scroll offset (0 to max scroll)
            local maxScroll = 100 -- Allow scrolling down 100 pixels
            self.menuScrollOffset = math.max(0, math.min(maxScroll, self.menuScrollOffset))
        end
        
        -- Handle down button scrolling
        if playdate.buttonJustPressed(playdate.kButtonDown) then
            self.menuScrollOffset = self.menuScrollOffset + 20 -- Scroll down by 20 pixels
            local maxScroll = 100
            self.menuScrollOffset = math.max(0, math.min(maxScroll, self.menuScrollOffset))
        end
        
        -- Handle up button scrolling
        if playdate.buttonJustPressed(playdate.kButtonUp) then
            self.menuScrollOffset = self.menuScrollOffset - 20 -- Scroll up by 20 pixels
            local maxScroll = 100
            self.menuScrollOffset = math.max(0, math.min(maxScroll, self.menuScrollOffset))
        end
        
        -- Start game on A button
        if self.inputHandler:isStartPressed() then
            self:init()
        end
    end
end

function GameManager:updatePlaying(dt)
    -- Handle playing state
    
    -- If we're animating line clears, update animation
    if self.clearingLines then
        self:updateClearAnimation(dt)
        return
    end
    
    -- Check for pause input
    if self.inputHandler then
        self.inputHandler:update(dt)
        
        if self.inputHandler:isPausePressed() then
            self:pause()
            return
        end
        
        -- Handle player input
        self:handleInput()
    end
    
    -- Update game state (piece falling, locking, etc.)
    self.gameState:update(dt)
    
    -- Check for line clears
    local linesCleared = self.playfield:checkLines()
    if linesCleared and #linesCleared > 0 then
        -- Start line clear animation
        self:startClearAnimation(linesCleared)
    end
    
    -- Check for game over
    if self.gameState:isGameOver() then
        self:changeState("gameover")
    end
end

function GameManager:updatePaused(dt)
    -- Handle paused state
    
    -- Check for unpause input
    if self.inputHandler then
        self.inputHandler:update(dt)
        
        if self.inputHandler:isPausePressed() then
            self:unpause()
        end
    end
end

function GameManager:updateGameOver(dt)
    -- Handle game over state
    
    -- Check for restart input
    if self.inputHandler then
        self.inputHandler:update(dt)
        
        -- Restart game on A button
        if self.inputHandler:isStartPressed() then
            self:init()
        end
    end
end

function GameManager:handleInput()
    -- Process player input during gameplay
    
    if not self.inputHandler then
        return
    end
    
    -- Handle crank rotation
    local crankRotation = self.inputHandler:getCrankRotation()
    if crankRotation ~= 0 then
        local direction = crankRotation > 0 and 1 or -1
        local rotated = self.gameState:rotateCurrentPiece(direction)
        
        -- Provide haptic feedback on successful rotation
        if rotated and playdate and playdate.cranked then
            -- Haptic feedback would go here
            -- playdate.crankHaptic() or similar
        end
    end
    
    -- Handle B button rotation (clockwise)
    if self.inputHandler:isRotateButtonPressed() then
        self.gameState:rotateCurrentPiece(1) -- Clockwise rotation
    end
    
    -- Handle horizontal movement
    local movement = self.inputHandler:getMovement()
    if movement ~= 0 then
        self.gameState:moveCurrentPiece(movement, 0)
    end
    
    -- Handle soft drop (down button held)
    local isSoftDropping = self.inputHandler:isSoftDropActive()
    self.gameState:setSoftDrop(isSoftDropping)
    
    -- Handle hard drop (Up button)
    if self.inputHandler:isHardDropPressed() then
        self.gameState:hardDrop()
    end
end

function GameManager:changeState(newState)
    -- Change the game state
    local validStates = {start_screen = true, menu = true, playing = true, paused = true, gameover = true}
    
    if not validStates[newState] then
        error("Invalid game state: " .. tostring(newState))
    end
    
    self.state = newState
end

function GameManager:pause()
    -- Pause the game
    if self.state == "playing" then
        self.state = "paused"
        self.gameState:pause()
    end
end

function GameManager:unpause()
    -- Resume the game
    if self.state == "paused" then
        self.state = "playing"
        self.gameState:unpause()
    end
end

function GameManager:isPlaying()
    return self.state == "playing"
end

function GameManager:isPaused()
    return self.state == "paused"
end

function GameManager:isGameOver()
    return self.state == "gameover"
end

function GameManager:getState()
    return self.state
end

function GameManager:startClearAnimation(lines)
    -- Start the line clear animation
    self.clearingLines = lines
    self.clearAnimationTimer = 0
end

function GameManager:updateClearAnimation(dt)
    -- Update the line clear animation
    self.clearAnimationTimer = self.clearAnimationTimer + dt
    
    if self.clearAnimationTimer >= self.clearAnimationDuration then
        -- Animation complete - actually clear the lines
        local lineCount = #self.clearingLines
        self.playfield:clearLines(self.clearingLines)
        self.scoreManager:addLines(lineCount)
        
        -- Update fall speed based on new level
        self.gameState.fallInterval = self.scoreManager:getFallSpeed()
        
        -- Reset animation state
        self.clearingLines = nil
        self.clearAnimationTimer = 0
    end
end

function GameManager:getClearAnimation()
    -- Return current animation state for rendering
    if not self.clearingLines then
        return nil
    end
    
    return {
        lines = self.clearingLines,
        progress = self.clearAnimationTimer / self.clearAnimationDuration
    }
end

-- Export module (compatible with both require and import)
if _G then
    _G.GameManager = GameManager
end
return GameManager

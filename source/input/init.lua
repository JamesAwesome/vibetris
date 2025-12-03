-- Input module: Handles player input from crank, D-pad, and buttons
-- Processes crank rotation, D-pad movement with auto-repeat, and button presses

local InputHandler = {}
InputHandler.__index = InputHandler

function InputHandler:new()
    local self = setmetatable({}, InputHandler)
    
    -- Crank state
    self.lastCrankAngle = 0
    self.crankThreshold = 25 -- Degrees of rotation needed to trigger rotation (tuned for better feel)
    self.crankAccumulator = 0
    
    -- D-pad auto-repeat state
    self.leftHoldTime = 0
    self.rightHoldTime = 0
    self.downHoldTime = 0
    self.autoRepeatDelay = 0.25 -- Initial delay before auto-repeat starts (increased to prevent accidental double moves)
    self.autoRepeatRate = 0.05 -- Time between auto-repeats (tuned for smooth movement)
    self.repeatTimer = 0
    
    -- Button state
    self.hardDropPressed = false
    self.pausePressed = false
    
    -- Soft drop state
    self.isSoftDropping = false
    
    return self
end

function InputHandler:update(dt)
    -- Update input state with delta time
    -- This should be called every frame
    
    -- Update D-pad hold timers
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.leftHoldTime = self.leftHoldTime + dt
    else
        self.leftHoldTime = 0
    end
    
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.rightHoldTime = self.rightHoldTime + dt
    else
        self.rightHoldTime = 0
    end
    
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.downHoldTime = self.downHoldTime + dt
        self.isSoftDropping = true
    else
        self.downHoldTime = 0
        self.isSoftDropping = false
    end
    
    -- Update repeat timer
    self.repeatTimer = self.repeatTimer + dt
end

function InputHandler:getCrankRotation()
    -- Get crank rotation direction if threshold is exceeded
    -- Returns: 1 for clockwise, -1 for counter-clockwise, 0 for no rotation
    
    local currentAngle = playdate.getCrankPosition()
    local change = playdate.getCrankChange()
    
    -- Accumulate crank movement
    self.crankAccumulator = self.crankAccumulator + change
    
    -- Check if threshold is exceeded
    if self.crankAccumulator >= self.crankThreshold then
        self.crankAccumulator = 0
        return 1 -- Clockwise
    elseif self.crankAccumulator <= -self.crankThreshold then
        self.crankAccumulator = 0
        return -1 -- Counter-clockwise
    end
    
    return 0 -- No rotation
end

function InputHandler:getMovement()
    -- Get horizontal movement direction with auto-repeat
    -- Returns: -1 for left, 1 for right, 0 for no movement
    
    -- Check for initial press or auto-repeat
    local leftPressed = playdate.buttonJustPressed(playdate.kButtonLeft)
    local rightPressed = playdate.buttonJustPressed(playdate.kButtonRight)
    
    -- Handle initial press
    if leftPressed then
        self.repeatTimer = 0
        return -1
    end
    
    if rightPressed then
        self.repeatTimer = 0
        return 1
    end
    
    -- Handle auto-repeat
    if self.leftHoldTime > self.autoRepeatDelay then
        if self.repeatTimer >= self.autoRepeatRate then
            self.repeatTimer = 0
            return -1
        end
    end
    
    if self.rightHoldTime > self.autoRepeatDelay then
        if self.repeatTimer >= self.autoRepeatRate then
            self.repeatTimer = 0
            return 1
        end
    end
    
    return 0
end

function InputHandler:isHardDropPressed()
    -- Check if hard drop button (Up) was just pressed
    return playdate.buttonJustPressed(playdate.kButtonUp)
end

function InputHandler:isStartPressed()
    -- Check if start button (A) was just pressed
    return playdate.buttonJustPressed(playdate.kButtonA)
end

function InputHandler:isFPSTogglePressed()
    -- Check if FPS toggle button (B) was just pressed
    return playdate.buttonJustPressed(playdate.kButtonB)
end

function InputHandler:isPausePressed()
    -- Check if pause button (menu) was just pressed
    return playdate.buttonJustPressed(playdate.kButtonMenu)
end

function InputHandler:isSoftDropActive()
    -- Check if soft drop (down button) is currently held
    return self.isSoftDropping
end

function InputHandler:provideHapticFeedback()
    -- Provide haptic feedback through the crank
    -- This is called when a rotation is successful
    -- The Playdate SDK doesn't have explicit haptic feedback API for crank
    -- but we can use the crank indicator to provide visual feedback
    playdate.ui.crankIndicator:start()
end

-- Export module (compatible with both require and import)
if _G then
    _G.InputHandler = InputHandler
end
return InputHandler

# InputHandler Integration Guide

## Overview

The InputHandler class processes all player input from the Playdate's crank, D-pad, and buttons. It provides a clean interface for the game state to query input events.

## Usage Example

```lua
local InputHandler = require("input/init")
local GameState = require("game/state")

-- Initialize
local inputHandler = InputHandler:new()
local gameState = GameState:new(playfield, factory, collisionDetector)

-- In playdate.update()
function playdate.update()
    local dt = 1/30  -- Assuming 30 FPS
    
    -- Update input state
    inputHandler:update(dt)
    
    -- Handle pause/unpause
    if inputHandler:isPausePressed() then
        if gameState.state == "playing" then
            gameState:pause()
        elseif gameState.state == "paused" then
            gameState:unpause()
        end
    end
    
    -- Only process game input when playing
    if gameState.state == "playing" then
        -- Handle crank rotation
        local rotation = inputHandler:getCrankRotation()
        if rotation ~= 0 then
            local success = gameState:rotateCurrentPiece(rotation)
            if success then
                inputHandler:provideHapticFeedback()
            end
        end
        
        -- Handle horizontal movement
        local movement = inputHandler:getMovement()
        if movement ~= 0 then
            gameState:moveCurrentPiece(movement, 0)
        end
        
        -- Handle soft drop
        gameState:setSoftDrop(inputHandler:isSoftDropActive())
        
        -- Handle hard drop
        if inputHandler:isHardDropPressed() then
            gameState:hardDrop()
        end
    end
    
    -- Update game state
    gameState:update(dt)
    
    -- Render (handled by rendering module)
    -- ...
end
```

## API Reference

### InputHandler:new()
Creates a new InputHandler instance.

### InputHandler:update(dt)
Updates input state. Call this every frame with delta time in seconds.

**Parameters:**
- `dt` (number): Delta time in seconds since last frame

### InputHandler:getCrankRotation()
Gets crank rotation direction if threshold is exceeded.

**Returns:**
- `1` for clockwise rotation
- `-1` for counter-clockwise rotation
- `0` for no rotation

### InputHandler:getMovement()
Gets horizontal movement direction with auto-repeat.

**Returns:**
- `-1` for left movement
- `1` for right movement
- `0` for no movement

### InputHandler:isHardDropPressed()
Checks if hard drop button (A) was just pressed.

**Returns:**
- `true` if A button was just pressed
- `false` otherwise

### InputHandler:isPausePressed()
Checks if pause button (menu) was just pressed.

**Returns:**
- `true` if menu button was just pressed
- `false` otherwise

### InputHandler:isSoftDropActive()
Checks if soft drop (down button) is currently held.

**Returns:**
- `true` if down button is held
- `false` otherwise

### InputHandler:provideHapticFeedback()
Provides visual feedback for successful rotations by showing the crank indicator.

## Configuration

You can adjust these parameters in the InputHandler constructor:

- `crankThreshold`: Degrees of rotation needed to trigger rotation (default: 30)
- `autoRepeatDelay`: Initial delay before auto-repeat starts in seconds (default: 0.15)
- `autoRepeatRate`: Time between auto-repeats in seconds (default: 0.05)

## Requirements Satisfied

- ✅ 2.1: Crank clockwise rotation
- ✅ 2.2: Crank counter-clockwise rotation
- ✅ 2.5: Haptic feedback for successful rotations
- ✅ 3.1: Left D-pad movement
- ✅ 3.2: Right D-pad movement
- ✅ 3.4: D-pad auto-repeat
- ✅ 4.1: Soft drop (down button)
- ✅ 4.2: Release down button restores speed
- ✅ 4.3: Hard drop (A button)
- ✅ 9.1: Pause button (menu)
- ✅ 9.3: Resume from pause

-- Unit test for A button hard drop
-- Verifies that A button triggers hard drop during gameplay

-- Add source to package path
package.path = package.path .. ";./source/?.lua"

-- Mock Playdate SDK with controllable button states
local mockButtonStates = {}

_G.playdate = {
    graphics = {
        clear = function() end,
        drawRect = function() end,
        fillRect = function() end,
        drawText = function() end,
    },
    timer = {
        updateTimers = function() end,
    },
    getCrankPosition = function() return 0 end,
    getCrankChange = function() return 0 end,
    buttonIsPressed = function(button) return mockButtonStates[button] or false end,
    buttonJustPressed = function(button) return mockButtonStates[button] or false end,
    drawFPS = function() end,
    kButtonLeft = 1,
    kButtonRight = 2,
    kButtonDown = 3,
    kButtonUp = 4,
    kButtonA = 6,
    kButtonB = 7,
    kButtonMenu = 5,
}

local InputHandler = require("input/init")

print("\n=== A Button Hard Drop Tests ===")

-- Test 1: A button triggers hard drop
local function test_a_button_triggers_hard_drop()
    local inputHandler = InputHandler:new()
    
    -- Reset mock states
    mockButtonStates = {}
    
    -- Simulate A button press
    mockButtonStates[playdate.kButtonA] = true
    
    local isHardDrop = inputHandler:isHardDropPressed()
    
    assert(isHardDrop == true, "A button should trigger hard drop")
    
    print("✓ A button triggers hard drop")
    return true
end

-- Test 2: Up button still triggers hard drop
local function test_up_button_still_triggers_hard_drop()
    local inputHandler = InputHandler:new()
    
    -- Reset mock states
    mockButtonStates = {}
    
    -- Simulate Up button press
    mockButtonStates[playdate.kButtonUp] = true
    
    local isHardDrop = inputHandler:isHardDropPressed()
    
    assert(isHardDrop == true, "Up button should still trigger hard drop")
    
    print("✓ Up button still triggers hard drop")
    return true
end

-- Test 3: Either A or Up button triggers hard drop
local function test_either_button_triggers_hard_drop()
    local inputHandler = InputHandler:new()
    
    -- Test with A button
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonA] = true
    assert(inputHandler:isHardDropPressed() == true, "A button should trigger hard drop")
    
    -- Test with Up button
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonUp] = true
    assert(inputHandler:isHardDropPressed() == true, "Up button should trigger hard drop")
    
    -- Test with both buttons (edge case)
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonA] = true
    mockButtonStates[playdate.kButtonUp] = true
    assert(inputHandler:isHardDropPressed() == true, "Both buttons should trigger hard drop")
    
    print("✓ Either A or Up button triggers hard drop")
    return true
end

-- Test 4: No button press means no hard drop
local function test_no_button_no_hard_drop()
    local inputHandler = InputHandler:new()
    
    -- Reset mock states (no buttons pressed)
    mockButtonStates = {}
    
    local isHardDrop = inputHandler:isHardDropPressed()
    
    assert(isHardDrop == false, "No button press should not trigger hard drop")
    
    print("✓ No button press means no hard drop")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_a_button_triggers_hard_drop()
all_passed = all_passed and test_up_button_still_triggers_hard_drop()
all_passed = all_passed and test_either_button_triggers_hard_drop()
all_passed = all_passed and test_no_button_no_hard_drop()

if all_passed then
    print("\n✓ All A button hard drop tests passed!")
else
    print("\n✗ Some A button hard drop tests failed!")
    os.exit(1)
end

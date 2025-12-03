-- Unit test for menu scrolling behavior
-- Verifies that menu scrolls correctly with crank and D-pad buttons

-- Add source to package path
package.path = package.path .. ";./source/?.lua"

-- Mock Playdate SDK with controllable button states
local mockButtonStates = {}
local mockCrankChange = 0

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
    getCrankChange = function() return mockCrankChange end,
    buttonIsPressed = function(button) return mockButtonStates[button] or false end,
    buttonJustPressed = function(button) return mockButtonStates[button] or false end,
    drawFPS = function() end,
    kButtonLeft = 1,
    kButtonRight = 2,
    kButtonDown = 3,
    kButtonUp = 4,
    kButtonA = 6,
    kButtonMenu = 5,
}

local game = require("game/init")
local pieces = require("pieces/init")

print("\n=== Menu Scrolling Tests ===")

-- Helper function to create a GameManager in menu state
local function createMenuManager()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState
    )
    
    -- Reset mock states
    mockButtonStates = {}
    mockCrankChange = 0
    
    return manager
end

-- Test 1: Initial scroll offset is zero
local function test_initial_scroll_offset()
    local manager = createMenuManager()
    
    assert(manager.menuScrollOffset == 0, "Initial scroll offset should be 0")
    
    print("✓ Initial scroll offset is zero")
    return true
end

-- Test 2: Clockwise crank rotation scrolls down
local function test_crank_clockwise_scrolls_down()
    local manager = createMenuManager()
    
    -- Simulate clockwise crank rotation (positive change)
    mockCrankChange = 10
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 10, "Clockwise rotation should scroll down (increase offset)")
    
    print("✓ Clockwise crank rotation scrolls down")
    return true
end

-- Test 3: Counter-clockwise crank rotation scrolls up
local function test_crank_counterclockwise_scrolls_up()
    local manager = createMenuManager()
    
    -- Set initial scroll offset
    manager.menuScrollOffset = 50
    
    -- Simulate counter-clockwise crank rotation (negative change)
    mockCrankChange = -10
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 40, "Counter-clockwise rotation should scroll up (decrease offset)")
    
    print("✓ Counter-clockwise crank rotation scrolls up")
    return true
end

-- Test 4: Down button scrolls down
local function test_down_button_scrolls_down()
    local manager = createMenuManager()
    
    -- Simulate down button press
    mockButtonStates[playdate.kButtonDown] = true
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 20, "Down button should scroll down by 20 pixels")
    
    print("✓ Down button scrolls down")
    return true
end

-- Test 5: Up button scrolls up
local function test_up_button_scrolls_up()
    local manager = createMenuManager()
    
    -- Set initial scroll offset
    manager.menuScrollOffset = 50
    
    -- Simulate up button press
    mockButtonStates[playdate.kButtonUp] = true
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 30, "Up button should scroll up by 20 pixels")
    
    print("✓ Up button scrolls up")
    return true
end

-- Test 6: Scroll offset is clamped to minimum (0)
local function test_scroll_clamp_minimum()
    local manager = createMenuManager()
    
    -- Try to scroll up from 0
    mockCrankChange = -50
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 0, "Scroll offset should not go below 0")
    
    print("✓ Scroll offset is clamped to minimum")
    return true
end

-- Test 7: Scroll offset is clamped to maximum (100)
local function test_scroll_clamp_maximum()
    local manager = createMenuManager()
    
    -- Try to scroll down beyond maximum
    mockCrankChange = 150
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 100, "Scroll offset should not exceed 100")
    
    print("✓ Scroll offset is clamped to maximum")
    return true
end

-- Test 8: Multiple scroll inputs accumulate correctly
local function test_multiple_scroll_inputs()
    local manager = createMenuManager()
    
    -- First scroll down with crank
    mockCrankChange = 10
    manager:updateMenu(0.016)
    
    -- Reset crank change
    mockCrankChange = 0
    
    -- Then scroll down with button
    mockButtonStates[playdate.kButtonDown] = true
    manager:updateMenu(0.016)
    
    assert(manager.menuScrollOffset == 30, "Multiple scroll inputs should accumulate (10 + 20)")
    
    print("✓ Multiple scroll inputs accumulate correctly")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_initial_scroll_offset()
all_passed = all_passed and test_crank_clockwise_scrolls_down()
all_passed = all_passed and test_crank_counterclockwise_scrolls_up()
all_passed = all_passed and test_down_button_scrolls_down()
all_passed = all_passed and test_up_button_scrolls_up()
all_passed = all_passed and test_scroll_clamp_minimum()
all_passed = all_passed and test_scroll_clamp_maximum()
all_passed = all_passed and test_multiple_scroll_inputs()

if all_passed then
    print("\n✓ All menu scrolling tests passed!")
else
    print("\n✗ Some menu scrolling tests failed!")
    os.exit(1)
end

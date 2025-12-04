-- Unit Test: Start Screen State Transitions
-- Tests that start screen displays on launch and transitions correctly
-- Requirements: 2.4

package.path = package.path .. ";./source/?.lua;../source/?.lua"

-- Mock Playdate SDK
_G.playdate = {
    graphics = {
        clear = function() end,
        drawRect = function() end,
        fillRect = function() end,
        drawText = function() end,
        getTextSize = function(text) return #text * 8, 16 end,
        setImageDrawMode = function() end,
        setFont = function() end,
        getSystemFont = function() return {} end,
        image = {
            new = function(path)
                -- Simulate logo loading
                return {
                    getSize = function() return 300, 80 end,
                    draw = function(x, y) end
                }
            end,
        },
        kDrawModeFillBlack = 0,
        kDrawModeFillWhite = 1,
    },
    timer = {
        updateTimers = function() end,
    },
    getCrankPosition = function() return 0 end,
    getCrankChange = function() return 0 end,
    buttonIsPressed = function() return false end,
    buttonJustPressed = function(button) return false end,
    drawFPS = function() end,
    kButtonLeft = 1,
    kButtonRight = 2,
    kButtonDown = 3,
    kButtonUp = 4,
    kButtonMenu = 5,
    kButtonA = 6,
    kButtonB = 7,
}

local game = require("game/init")
local pieces = require("pieces/init")
local StartScreen = require("ui/start_screen")

print("\n=== Unit Tests: Start Screen State Transitions ===")

-- Test 1: Start screen displays on launch
local function test_start_screen_displays_on_launch()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local startScreen = StartScreen:new()
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, startScreen
    )
    
    -- Verify initial state is start_screen
    assert(manager.state == "start_screen", "Initial state should be 'start_screen'")
    assert(startScreen:isDisplayed(), "Start screen should be displayed on launch")
    
    print("✓ Start screen displays on launch")
    return true
end

-- Test 2: Transition to menu after timeout
local function test_transition_after_timeout()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local startScreen = StartScreen:new()
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, startScreen
    )
    
    -- Verify we start in start_screen state
    assert(manager.state == "start_screen", "Should start in start_screen state")
    
    -- Update for less than display duration
    manager:update(1.0)
    assert(manager.state == "start_screen", "Should still be in start_screen state before timeout")
    
    -- Update past display duration (2.0 seconds total)
    manager:update(1.5)
    assert(manager.state == "menu", "Should transition to menu after timeout")
    
    print("✓ Transition to menu after timeout")
    return true
end

-- Test 3: Transition on button press
local function test_transition_on_button_press()
    -- Mock A button press
    _G.playdate.buttonJustPressed = function(button)
        return button == _G.playdate.kButtonA
    end
    
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local startScreen = StartScreen:new()
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, startScreen
    )
    
    -- Verify we start in start_screen state
    assert(manager.state == "start_screen", "Should start in start_screen state")
    
    -- Update with A button pressed (should transition immediately)
    manager:update(0.1)
    assert(manager.state == "menu", "Should transition to menu on A button press")
    
    -- Reset button mock
    _G.playdate.buttonJustPressed = function(button) return false end
    
    print("✓ Transition on button press")
    return true
end

-- Test 4: Start screen state update method
local function test_start_screen_update_method()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local startScreen = StartScreen:new()
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, startScreen
    )
    
    -- Verify updateStartScreen method exists and works
    assert(type(manager.updateStartScreen) == "function", "updateStartScreen method should exist")
    
    -- Call updateStartScreen directly
    manager:updateStartScreen(0.5)
    assert(manager.state == "start_screen", "Should remain in start_screen state")
    
    -- Update past timeout
    manager:updateStartScreen(2.0)
    assert(manager.state == "menu", "Should transition to menu")
    
    print("✓ Start screen update method")
    return true
end

-- Test 5: No start screen (fallback to menu)
local function test_no_start_screen_fallback()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    -- Create manager without start screen
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    -- Should still start in start_screen state
    assert(manager.state == "start_screen", "Should start in start_screen state")
    
    -- Update should transition immediately to menu when no start screen
    manager:update(0.016)
    assert(manager.state == "menu", "Should transition to menu immediately when no start screen")
    
    print("✓ No start screen fallback")
    return true
end

-- Test 6: Start screen to menu to playing flow
local function test_full_state_flow()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local startScreen = StartScreen:new()
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, startScreen
    )
    
    -- Start in start_screen
    assert(manager.state == "start_screen", "Should start in start_screen state")
    
    -- Transition to menu
    manager:update(2.5)
    assert(manager.state == "menu", "Should be in menu state")
    
    -- Transition to playing
    manager:init()
    assert(manager.state == "playing", "Should be in playing state")
    
    print("✓ Full state flow (start_screen -> menu -> playing)")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_start_screen_displays_on_launch()
all_passed = all_passed and test_transition_after_timeout()
all_passed = all_passed and test_transition_on_button_press()
all_passed = all_passed and test_start_screen_update_method()
all_passed = all_passed and test_no_start_screen_fallback()
all_passed = all_passed and test_full_state_flow()

if all_passed then
    print("\n✓ All start screen state transition tests passed!")
else
    print("\n✗ Some start screen state transition tests failed!")
    os.exit(1)
end

-- Integration test for GameManager
-- Verifies that GameManager correctly wires together all game components

-- Add source to package path
package.path = package.path .. ";./source/?.lua"

-- Mock Playdate SDK
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
    buttonIsPressed = function() return false end,
    buttonJustPressed = function() return false end,
    drawFPS = function() end,
    kButtonLeft = 1,
    kButtonRight = 2,
    kButtonDown = 3,
    kButtonUp = 4,
    kButtonMenu = 5,
}

local game = require("game/init")
local pieces = require("pieces/init")

print("\n=== GameManager Integration Tests ===")

-- Test 1: GameManager initialization
local function test_initialization()
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
    
    assert(manager ~= nil, "GameManager should be created")
    assert(manager.state == "menu", "Initial state should be 'menu'")
    assert(manager.playfield ~= nil, "Playfield should be set")
    assert(manager.factory ~= nil, "Factory should be set")
    assert(manager.scoreManager ~= nil, "ScoreManager should be set")
    
    print("✓ GameManager initialization")
    return true
end

-- Test 2: State transitions
local function test_state_transitions()
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
    
    -- Test menu -> playing
    manager:init()
    assert(manager.state == "playing", "State should be 'playing' after init")
    
    -- Test playing -> paused
    manager:pause()
    assert(manager.state == "paused", "State should be 'paused' after pause")
    assert(manager:isPaused(), "isPaused() should return true")
    
    -- Test paused -> playing
    manager:unpause()
    assert(manager.state == "playing", "State should be 'playing' after unpause")
    assert(manager:isPlaying(), "isPlaying() should return true")
    
    -- Test playing -> gameover
    manager:changeState("gameover")
    assert(manager.state == "gameover", "State should be 'gameover'")
    assert(manager:isGameOver(), "isGameOver() should return true")
    
    print("✓ State transitions")
    return true
end

-- Test 3: Component integration
local function test_component_integration()
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
    
    manager:init()
    
    -- Verify all components are properly initialized
    assert(manager.gameState ~= nil, "GameState should be initialized")
    assert(manager.gameState.currentPiece ~= nil, "Current piece should exist")
    assert(manager.gameState.nextPiece ~= nil, "Next piece should exist")
    assert(manager.scoreManager:getScore() == 0, "Initial score should be 0")
    assert(manager.scoreManager:getLevel() == 1, "Initial level should be 1")
    
    print("✓ Component integration")
    return true
end

-- Test 4: Update loop
local function test_update_loop()
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
    
    manager:init()
    
    -- Update should not crash
    manager:update(0.016) -- ~60 FPS
    
    -- Verify game state is still valid
    assert(manager.gameState.currentPiece ~= nil, "Current piece should still exist")
    
    print("✓ Update loop")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_initialization()
all_passed = all_passed and test_state_transitions()
all_passed = all_passed and test_component_integration()
all_passed = all_passed and test_update_loop()

if all_passed then
    print("\n✓ All GameManager integration tests passed!")
else
    print("\n✗ Some GameManager integration tests failed!")
    os.exit(1)
end

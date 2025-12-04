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
        scoreManager, inputHandler, gameState, nil
    )
    
    assert(manager ~= nil, "GameManager should be created")
    assert(manager.state == "start_screen", "Initial state should be 'start_screen'")
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
        scoreManager, inputHandler, gameState, nil
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
        scoreManager, inputHandler, gameState, nil
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
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    
    -- Update should not crash
    manager:update(0.016) -- ~60 FPS
    
    -- Verify game state is still valid
    assert(manager.gameState.currentPiece ~= nil, "Current piece should still exist")
    
    print("✓ Update loop")
    return true
end

-- Test 5: Playing state update
local function test_playing_state_update()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    
    -- Simulate playing state update
    manager:updatePlaying(0.016)
    
    -- Verify game is still in playing state
    assert(manager.state == "playing", "Should remain in playing state")
    
    print("✓ Playing state update")
    return true
end

-- Test 6: Paused state update
local function test_paused_state_update()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    manager:pause()
    
    -- Simulate paused state update
    manager:updatePaused(0.016)
    
    -- Verify game is still paused
    assert(manager.state == "paused", "Should remain in paused state")
    
    print("✓ Paused state update")
    return true
end

-- Test 7: Game over state update
local function test_gameover_state_update()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    manager:changeState("gameover")
    
    -- Simulate gameover state update
    manager:updateGameOver(0.016)
    
    -- Verify game is still in gameover state
    assert(manager.state == "gameover", "Should remain in gameover state")
    
    print("✓ Game over state update")
    return true
end

-- Test 8: Line clear animation
local function test_line_clear_animation()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    
    -- Start a line clear animation
    manager:startClearAnimation({1, 2})
    
    assert(manager.clearingLines ~= nil, "Clearing lines should be set")
    assert(#manager.clearingLines == 2, "Should be clearing 2 lines")
    assert(manager.clearAnimationTimer == 0, "Timer should start at 0")
    
    -- Get animation state
    local anim = manager:getClearAnimation()
    assert(anim ~= nil, "Animation state should exist")
    assert(anim.lines ~= nil, "Animation should have lines")
    assert(anim.progress >= 0, "Animation progress should be >= 0")
    
    print("✓ Line clear animation")
    return true
end

-- Test 9: Animation completion
local function test_animation_completion()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    
    -- Fill a line in the playfield
    for x = 1, 10 do
        playfield.grid[20][x] = "I"
    end
    
    -- Start animation
    manager:startClearAnimation({20})
    
    -- Update animation past completion time
    manager:updateClearAnimation(0.3) -- Duration is 0.25s
    
    -- Animation should be complete
    assert(manager.clearingLines == nil, "Animation should be complete")
    assert(manager:getClearAnimation() == nil, "No animation state should exist")
    
    print("✓ Animation completion")
    return true
end

-- Test 10: Handle input during gameplay
local function test_handle_input()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    manager:init()
    
    -- Call handleInput (should not crash)
    manager:handleInput()
    
    -- Verify game state is still valid
    assert(manager.gameState.currentPiece ~= nil, "Current piece should still exist")
    
    print("✓ Handle input")
    return true
end

-- Test 11: State getters
local function test_state_getters()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    local manager = game.GameManager:new(
        playfield, factory, collisionDetector, 
        scoreManager, inputHandler, gameState, nil
    )
    
    -- Test start_screen state (initial state)
    assert(manager:getState() == "start_screen", "Should be in start_screen state")
    assert(not manager:isPlaying(), "Should not be playing")
    assert(not manager:isPaused(), "Should not be paused")
    assert(not manager:isGameOver(), "Should not be game over")
    
    -- Test playing state
    manager:init()
    assert(manager:getState() == "playing", "Should be in playing state")
    assert(manager:isPlaying(), "Should be playing")
    
    -- Test paused state
    manager:pause()
    assert(manager:getState() == "paused", "Should be in paused state")
    assert(manager:isPaused(), "Should be paused")
    
    -- Test gameover state
    manager:changeState("gameover")
    assert(manager:getState() == "gameover", "Should be in gameover state")
    assert(manager:isGameOver(), "Should be game over")
    
    print("✓ State getters")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_initialization()
all_passed = all_passed and test_state_transitions()
all_passed = all_passed and test_component_integration()
all_passed = all_passed and test_update_loop()
all_passed = all_passed and test_playing_state_update()
all_passed = all_passed and test_paused_state_update()
all_passed = all_passed and test_gameover_state_update()
all_passed = all_passed and test_line_clear_animation()
all_passed = all_passed and test_animation_completion()
all_passed = all_passed and test_handle_input()
all_passed = all_passed and test_state_getters()

if all_passed then
    print("\n✓ All GameManager integration tests passed!")
else
    print("\n✗ Some GameManager integration tests failed!")
    os.exit(1)
end

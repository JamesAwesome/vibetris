-- Unit test for A button restart from game over
-- Verifies that A button restarts the game from game over state

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
        setColor = function() end,
        setLineWidth = function() end,
        setPattern = function() end,
        setDitherPattern = function() end,
        setImageDrawMode = function() end,
        getTextSize = function() return 100 end,
        image = {kDitherTypeBayer4x4 = 1},
        kColorBlack = 0,
        kColorWhite = 1,
        kDrawModeFillBlack = 0,
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

-- Load game modules
local game = require("game/init")
local pieces = require("pieces/init")

print("\n=== A Button Restart Tests ===")

-- Test 1: A button restarts game from game over state
local function test_a_button_restarts_game()
    -- Create game components
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    -- Create game manager
    local gameManager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState,
        nil
    )
    
    -- Set game to game over state
    gameManager:changeState("gameover")
    assert(gameManager:getState() == "gameover", "Game should be in gameover state")
    
    -- Simulate A button press
    mockButtonStates[playdate.kButtonA] = true
    
    -- Update game manager
    gameManager:update(0.016)
    
    -- Game should now be in playing state (restarted)
    assert(gameManager:getState() == "playing", "Game should restart to playing state after A button press")
    
    -- Clean up
    mockButtonStates[playdate.kButtonA] = false
    
    print("✓ A button restarts game from game over state")
    return true
end

-- Test 2: Other buttons don't restart from game over
local function test_other_buttons_dont_restart()
    -- Create game components
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    -- Create game manager
    local gameManager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState,
        nil
    )
    
    -- Set game to game over state
    gameManager:changeState("gameover")
    
    -- Try pressing B button
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonB] = true
    gameManager:update(0.016)
    assert(gameManager:getState() == "gameover", "B button should not restart game")
    
    -- Try pressing Up button
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonUp] = true
    gameManager:update(0.016)
    assert(gameManager:getState() == "gameover", "Up button should not restart game")
    
    -- Try pressing Down button
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonDown] = true
    gameManager:update(0.016)
    assert(gameManager:getState() == "gameover", "Down button should not restart game")
    
    print("✓ Other buttons don't restart from game over")
    return true
end

-- Test 3: Game state is properly reset after restart
local function test_game_state_reset_after_restart()
    -- Create game components
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local inputHandler = game.InputHandler:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    
    -- Create game manager and start game
    local gameManager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState,
        nil
    )
    gameManager:init()
    
    -- Modify score to simulate gameplay (clear 4 lines)
    gameManager.scoreManager:addLines(4)
    local oldScore = gameManager.scoreManager:getScore()
    local oldLines = gameManager.scoreManager:getTotalLines()
    assert(oldScore > 0, "Score should be greater than 0 after adding lines")
    assert(oldLines == 4, "Total lines should be 4 after adding 4 lines")
    
    -- Set to game over
    gameManager:changeState("gameover")
    
    -- Restart with A button
    mockButtonStates = {}
    mockButtonStates[playdate.kButtonA] = true
    gameManager:update(0.016)
    mockButtonStates[playdate.kButtonA] = false
    
    -- Check that score was reset
    local newScore = gameManager.scoreManager:getScore()
    assert(newScore == 0, "Score should be reset to 0 after restart")
    
    -- Check that game is playing
    assert(gameManager:getState() == "playing", "Game should be in playing state")
    
    print("✓ Game state is properly reset after restart")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_a_button_restarts_game()
all_passed = all_passed and test_other_buttons_dont_restart()
all_passed = all_passed and test_game_state_reset_after_restart()

if all_passed then
    print("\n✓ All A button restart tests passed!")
else
    print("\n✗ Some A button restart tests failed!")
    os.exit(1)
end

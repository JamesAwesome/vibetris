-- Test line clear animation behavior
-- Verifies that animation doesn't block game logic and completes properly

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
    kButtonA = 4,
    kButtonMenu = 5,
}

-- Import required modules
local game = require("game/init")
local pieces = require("pieces/init")

print("\n=== Unit Tests: Line Clear Animation ===")

local passed = 0
local failed = 0

local function test_assert(condition, message)
    if not condition then
        print("✗ " .. message)
        failed = failed + 1
        error(message)
    end
end

local function run_test(name, fn)
    local success, err = pcall(fn)
    if success then
        print("✓ " .. name)
        passed = passed + 1
    else
        print("✗ " .. name .. ": " .. tostring(err))
        failed = failed + 1
    end
end

-- Test 1: Animation starts when lines are detected
run_test("animation starts when lines are cleared", function()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local inputHandler = nil
    
    local manager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState
    )
    manager:init()
    
    -- Fill a complete line
    for x = 1, 10 do
        playfield.grid[20][x] = "I"
    end
    
    -- Update to trigger line clear detection
    manager:update(0.016) -- One frame
    
    -- Animation should have started
    local anim = manager:getClearAnimation()
    test_assert(anim ~= nil, "Animation should be active")
    test_assert(#anim.lines == 1, "Should be clearing 1 line")
    test_assert(anim.lines[1] == 20, "Should be clearing line 20")
end)

-- Test 2: Animation completes and clears lines
run_test("animation completes and clears lines", function()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local inputHandler = nil
    
    local manager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState
    )
    manager:init()
    
    -- Fill a complete line
    for x = 1, 10 do
        playfield.grid[20][x] = "I"
    end
    
    -- Start animation
    manager:update(0.016)
    
    -- Complete animation (duration is 0.3 seconds, add a bit extra to ensure completion)
    manager:update(0.35)
    
    -- Animation should be complete
    local anim = manager:getClearAnimation()
    test_assert(anim == nil, "Animation should be complete")
    
    -- Line should be cleared
    local hasBlocks = false
    for x = 1, 10 do
        if playfield.grid[20][x] ~= nil then
            hasBlocks = true
            break
        end
    end
    test_assert(not hasBlocks, "Line should be cleared")
    
    -- Score should be updated (check the manager's scoreManager, not the local one)
    test_assert(manager.scoreManager:getScore() > 0, "Score should be updated")
end)

-- Test 3: Game logic pauses during animation
run_test("game logic pauses during animation", function()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local inputHandler = nil
    
    local manager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState
    )
    manager:init()
    
    -- Fill a complete line
    for x = 1, 10 do
        playfield.grid[20][x] = "I"
    end
    
    -- Record initial piece position
    local initialY = gameState.currentPiece.y
    
    -- Start animation
    manager:update(0.016)
    
    -- Update during animation (should not move piece)
    manager:update(0.1)
    
    -- Piece should not have moved during animation
    test_assert(gameState.currentPiece.y == initialY, "Piece should not move during animation")
end)

-- Test 4: Multiple lines can be animated
run_test("multiple lines can be animated simultaneously", function()
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local collisionDetector = game.CollisionDetector
    local scoreManager = game.ScoreManager:new()
    local gameState = game.GameState:new(playfield, factory, collisionDetector)
    local inputHandler = nil
    
    local manager = game.GameManager:new(
        playfield,
        factory,
        collisionDetector,
        scoreManager,
        inputHandler,
        gameState
    )
    manager:init()
    
    -- Fill two complete lines
    for x = 1, 10 do
        playfield.grid[19][x] = "I"
        playfield.grid[20][x] = "I"
    end
    
    -- Start animation
    manager:update(0.016)
    
    -- Animation should include both lines
    local anim = manager:getClearAnimation()
    test_assert(anim ~= nil, "Animation should be active")
    test_assert(#anim.lines == 2, "Should be clearing 2 lines")
end)

print("\nUnit Tests: " .. passed .. " passed, " .. failed .. " failed")

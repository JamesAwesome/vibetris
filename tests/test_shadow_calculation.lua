-- Unit tests for shadow piece calculation
-- Tests shadow position calculation for various playfield states

local pieces = require("pieces/init")
local game = require("game/init")

print("\n=== Shadow Calculation Unit Tests ===")

local function testShadowCalculationEmptyPlayfield()
    -- Test shadow position calculation on empty playfield
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
    
    -- On empty playfield, shadow should be at the bottom
    local shadowY = gameState:calculateShadowY()
    
    -- Shadow should be at row 16 or higher (near bottom, accounting for piece shape)
    if shadowY >= 16 then
        print("✓ Shadow calculation on empty playfield")
        return true
    else
        print("✗ Shadow calculation on empty playfield - expected shadowY >= 16, got " .. tostring(shadowY))
        return false
    end
end

local function testShadowCalculationWithObstacles()
    -- Test shadow position calculation with obstacles below
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
    
    -- Add a floor of blocks at row 15 (using 1-based indexing)
    for x = 1, 10 do
        playfield.grid[15] = playfield.grid[15] or {}
        playfield.grid[15][x] = "X"
    end
    
    -- Recalculate shadow after adding obstacles
    local shadowY = gameState:calculateShadowY()
    
    -- Shadow should be above the floor (less than 15 in 0-based coordinates)
    if shadowY < 15 then
        print("✓ Shadow calculation with obstacles below")
        return true
    else
        print("✗ Shadow calculation with obstacles below - expected shadowY < 15, got " .. tostring(shadowY))
        return false
    end
end

local function testShadowCalculationAtBottom()
    -- Test shadow position when piece is already at bottom
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
    
    -- Move piece to near bottom
    local piece = gameState.currentPiece
    while game.CollisionDetector.canMoveTo(piece, playfield, piece.x, piece.y + 1) do
        piece.y = piece.y + 1
    end
    
    -- Calculate shadow
    local shadowY = gameState:calculateShadowY()
    
    -- Shadow should be at same position as piece
    if shadowY == piece.y then
        print("✓ Shadow calculation when piece is at bottom")
        return true
    else
        print("✗ Shadow calculation when piece is at bottom - expected shadowY == " .. piece.y .. ", got " .. tostring(shadowY))
        return false
    end
end

local function testShadowUpdateAfterMovement()
    -- Test shadow updates after piece movements
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
    
    local initialShadowY = gameState.shadowY
    
    -- Move piece horizontally
    gameState:moveCurrentPiece(1, 0)
    
    -- Shadow should still be calculated (may or may not change depending on obstacles)
    if gameState.shadowY ~= nil then
        print("✓ Shadow updates after horizontal movement")
        return true
    else
        print("✗ Shadow updates after horizontal movement - shadowY is nil")
        return false
    end
end

local function testShadowUpdateAfterRotation()
    -- Test shadow updates after rotation
    local playfield = game.Playfield:new(10, 20)
    local factory = pieces.TetrominoFactory:new()
    local gameState = game.GameState:new(playfield, factory, game.CollisionDetector)
    
    local initialShadowY = gameState.shadowY
    
    -- Rotate piece
    gameState:rotateCurrentPiece(1)
    
    -- Shadow should still be calculated
    if gameState.shadowY ~= nil then
        print("✓ Shadow updates after rotation")
        return true
    else
        print("✗ Shadow updates after rotation - shadowY is nil")
        return false
    end
end

-- Run all tests
local passed = 0
local failed = 0

if testShadowCalculationEmptyPlayfield() then passed = passed + 1 else failed = failed + 1 end
if testShadowCalculationWithObstacles() then passed = passed + 1 else failed = failed + 1 end
if testShadowCalculationAtBottom() then passed = passed + 1 else failed = failed + 1 end
if testShadowUpdateAfterMovement() then passed = passed + 1 else failed = failed + 1 end
if testShadowUpdateAfterRotation() then passed = passed + 1 else failed = failed + 1 end

print("\nShadow Calculation Tests: " .. passed .. " passed, " .. failed .. " failed")

if failed > 0 then
    os.exit(1)
end

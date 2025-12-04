import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

-- Import game modules
import "game/playfield"
import "pieces/init"
import "game/collision"
import "game/score"
import "input/init"
import "game/state"
import "game/manager"
import "rendering/init"
import "ui/start_screen"

-- Initialize game components
local playfield = Playfield:new(10, 20)
local factory = TetrominoFactory:new()
local collisionDetector = CollisionDetector
local scoreManager = ScoreManager:new()
local inputHandler = InputHandler:new()
local gameState = GameState:new(playfield, factory, collisionDetector)
local startScreen = StartScreen:new()
local gameManager = GameManager:new(playfield, factory, collisionDetector, scoreManager, inputHandler, gameState, startScreen)
local renderer = Renderer:new()

-- Set up system menu
local menu = playdate.getSystemMenu()

-- Add FPS toggle to system menu
local fpsMenuItem, error = menu:addCheckmarkMenuItem("Show FPS", false, function(value)
    gameManager.showFPS = value
end)

-- Track delta time
local lastTime = playdate.getCurrentTimeMilliseconds()

function playdate.update()
    -- Calculate delta time
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local dt = (currentTime - lastTime) / 1000.0 -- Convert to seconds
    lastTime = currentTime
    
    -- Cap delta time to prevent issues with large time jumps (e.g., when pausing)
    dt = math.min(dt, 0.1) -- Cap at 100ms
    
    -- Clear screen
    gfx.clear()
    
    -- Update game logic
    gameManager:update(dt)
    
    -- Render game
    renderer:render(gameManager)
    
    -- Update timers and sprites
    playdate.timer.updateTimers()
    gfx.sprite.update()
    
    -- Draw FPS counter if enabled
    if gameManager.showFPS then
        playdate.drawFPS(0, 0)
    end
end

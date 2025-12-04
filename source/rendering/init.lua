-- Rendering module: Draws all game elements to the screen
-- Handles playfield, pieces, UI, and game state screens

import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

local Renderer = {}
Renderer.__index = Renderer

-- Display constants
local SCREEN_WIDTH = 400
local SCREEN_HEIGHT = 240

-- Playfield rendering constants
local BLOCK_SIZE = 10
local PLAYFIELD_WIDTH = 10
local PLAYFIELD_HEIGHT = 20

-- Calculate centered positioning
-- Screen width: 400px
-- Playfield: 100px wide + 4px border = 104px
-- Gap between playfield and UI: 30px
-- UI section: ~90px (for text and preview box)
-- Moving further right for better centering
local PLAYFIELD_X = 110
local PLAYFIELD_Y = 20

-- UI positioning (playfield end + gap)
local UI_X = PLAYFIELD_X + (PLAYFIELD_WIDTH * BLOCK_SIZE) + 30
local UI_Y = 20  -- Align with top of playfield

-- Piece patterns for visual distinction (using different fill patterns)
-- Shadow piece uses {0x55, 0xAA, 0x55, 0xAA, ...} for 50% checkerboard dither
-- This creates a light gray appearance distinct from all active piece patterns
local PIECE_PATTERNS = {
    I = {0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55}, -- Diagonal lines
    O = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}, -- Solid
    T = {0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F}, -- Horizontal stripes
    S = {0xCC, 0xCC, 0xCC, 0xCC, 0x33, 0x33, 0x33, 0x33}, -- Checkerboard variant 1
    Z = {0x33, 0x33, 0x33, 0x33, 0xCC, 0xCC, 0xCC, 0xCC}, -- Checkerboard variant 2
    J = {0xE4, 0xE4, 0xE4, 0xE4, 0xE4, 0xE4, 0xE4, 0xE4}, -- Dense dots
    L = {0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88}, -- Sparse dots
}

function Renderer:new()
    local self = setmetatable({}, Renderer)
    
    -- Store pattern data for each piece type (will be used with setPattern)
    self.patterns = PIECE_PATTERNS
    
    -- Cache for UI labels (drawn once)
    self.uiLabelsDrawn = false
    
    return self
end

function Renderer:drawPlayfield(playfield, clearAnimation)
    -- Draw the playfield grid and locked blocks
    
    -- Draw playfield boundary (thicker for better visibility)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawRect(
        PLAYFIELD_X - 2, 
        PLAYFIELD_Y - 2, 
        PLAYFIELD_WIDTH * BLOCK_SIZE + 4, 
        PLAYFIELD_HEIGHT * BLOCK_SIZE + 4
    )
    
    -- Skip grid lines during animation for better performance
    if not clearAnimation then
        -- Draw grid lines (subtle) - one line per block
        gfx.setLineWidth(1)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(0.85, gfx.image.kDitherTypeBayer4x4)
        
        -- Draw vertical grid lines (one per column)
        for x = 1, PLAYFIELD_WIDTH - 1 do
            local screenX = PLAYFIELD_X + x * BLOCK_SIZE
            gfx.drawLine(screenX, PLAYFIELD_Y, screenX, PLAYFIELD_Y + PLAYFIELD_HEIGHT * BLOCK_SIZE)
        end
        
        -- Draw horizontal grid lines (one per row)
        for y = 1, PLAYFIELD_HEIGHT - 1 do
            local screenY = PLAYFIELD_Y + y * BLOCK_SIZE
            gfx.drawLine(PLAYFIELD_X, screenY, PLAYFIELD_X + PLAYFIELD_WIDTH * BLOCK_SIZE, screenY)
        end
    end
    
    -- Reset dither
    gfx.setColor(gfx.kColorBlack)
    
    -- Build set of lines being cleared for quick lookup
    local clearingLinesSet = {}
    if clearAnimation and clearAnimation.lines then
        for i = 1, #clearAnimation.lines do
            clearingLinesSet[clearAnimation.lines[i]] = true
        end
    end
    
    -- Draw locked blocks
    if playfield and playfield.grid then
        for y = 1, playfield.height do
            for x = 1, playfield.width do
                local blockType = playfield.grid[y][x]
                if blockType then
                    -- Check if this row is being cleared
                    local isClearing = clearingLinesSet[y]
                    self:drawBlock(x - 1, y - 1, blockType, isClearing, clearAnimation)
                end
            end
        end
    end
end

function Renderer:drawBlock(x, y, pieceType, isClearing, clearAnimation)
    -- Draw a single block at grid position (x, y) with the pattern for pieceType
    local screenX = PLAYFIELD_X + x * BLOCK_SIZE
    local screenY = PLAYFIELD_Y + y * BLOCK_SIZE
    
    -- Apply animation effect if this block is being cleared
    if isClearing and clearAnimation then
        -- Create a flashing effect by alternating between normal and inverted
        -- Flash 3 times during the animation
        local flashFrequency = 6 -- 3 full cycles (on/off)
        local flashPhase = math.floor(clearAnimation.progress * flashFrequency) % 2
        
        if flashPhase == 0 then
            -- Normal rendering
            local patternData = self.patterns[pieceType]
            if patternData then
                gfx.setPattern(patternData)
            else
                gfx.setColor(gfx.kColorBlack)
            end
            gfx.fillRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
            -- Draw block outline
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
        else
            -- Inverted rendering (white fill, black outline)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
        end
    else
        -- Normal rendering - batch fill and outline together
        local patternData = self.patterns[pieceType]
        if patternData then
            gfx.setPattern(patternData)
        else
            gfx.setColor(gfx.kColorBlack)
        end
        gfx.fillRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
    end
end

function Renderer:drawShadowPiece(piece, shadowY)
    -- Draw the shadow/ghost piece showing where the piece will land
    if not piece or not shadowY then
        return
    end
    
    -- Don't draw shadow if it's at the same position as the current piece
    if shadowY == piece.y then
        return
    end
    
    -- Get blocks for the current piece
    local blocks = piece:getBlocks()
    
    -- Calculate the Y offset between current position and shadow position
    local yOffset = shadowY - piece.y
    
    -- Draw each block at the shadow position with a dithered pattern
    for i = 1, #blocks do
        local block = blocks[i]
        -- Shadow block has same x, but y is offset by the difference
        local shadowBlockX = block.x
        local shadowBlockY = block.y + yOffset
        
        self:drawShadowBlock(shadowBlockX, shadowBlockY)
    end
end

function Renderer:drawShadowBlock(x, y)
    -- Draw a single shadow block with a distinctive dithered pattern
    local screenX = PLAYFIELD_X + x * BLOCK_SIZE
    local screenY = PLAYFIELD_Y + y * BLOCK_SIZE
    
    -- Use a 50% dithered checkerboard pattern for clear distinction from active pieces
    -- This creates a light gray appearance on the monochrome screen
    -- Pattern: alternating pixels in a checkerboard (0x55 = 01010101, 0xAA = 10101010)
    -- This is distinct from all active piece patterns which are denser or have different structures
    local shadowPattern = {0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA}
    gfx.setPattern(shadowPattern)
    gfx.fillRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
    
    -- Draw a subtle outline to define the block boundaries
    -- Using a lighter dither for the outline to keep it subtle
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
    gfx.drawRect(screenX, screenY, BLOCK_SIZE, BLOCK_SIZE)
    
    -- Reset to solid black for subsequent drawing
    gfx.setColor(gfx.kColorBlack)
end

function Renderer:drawPiece(piece)
    -- Draw the active falling piece
    if not piece then
        return
    end
    
    local blocks = piece:getBlocks()
    for i = 1, #blocks do
        local block = blocks[i]
        self:drawBlock(block.x, block.y, piece.type)
    end
end

function Renderer:drawUI(scoreManager, gameState)
    -- Draw score, level, lines cleared, and next piece preview
    
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    -- Draw UI labels and values
    local lineHeight = 18
    local sectionSpacing = 8
    local currentY = UI_Y
    
    -- Score
    gfx.drawText("*SCORE*", UI_X, currentY)
    currentY = currentY + lineHeight
    gfx.drawText(tostring(scoreManager:getScore()), UI_X, currentY)
    currentY = currentY + lineHeight + sectionSpacing
    
    -- Level
    gfx.drawText("*LEVEL*", UI_X, currentY)
    currentY = currentY + lineHeight
    gfx.drawText(tostring(scoreManager:getLevel()), UI_X, currentY)
    currentY = currentY + lineHeight + sectionSpacing
    
    -- Lines
    gfx.drawText("*LINES*", UI_X, currentY)
    currentY = currentY + lineHeight
    gfx.drawText(tostring(scoreManager:getTotalLines()), UI_X, currentY)
    currentY = currentY + lineHeight + sectionSpacing
    
    -- Next piece preview
    gfx.drawText("*NEXT*", UI_X, currentY)
    currentY = currentY + lineHeight + 5
    
    if gameState and gameState.nextPiece then
        self:drawNextPiecePreview(gameState.nextPiece, UI_X, currentY)
    end
end

function Renderer:drawNextPiecePreview(nextPieceType, x, y)
    -- Draw a preview of the next piece
    
    -- Get the piece shapes (SHAPES is globally available from pieces/init)
    -- SHAPES is already imported globally
    
    if not SHAPES[nextPieceType] then
        return
    end
    
    -- Draw preview box
    local previewSize = 50
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, previewSize, previewSize)
    
    -- Get the blocks for rotation 0
    local shapeBlocks = SHAPES[nextPieceType][0]
    
    -- Calculate center offset for preview
    local minX, maxX, minY, maxY = 999, -999, 999, -999
    for i = 1, #shapeBlocks do
        local block = shapeBlocks[i]
        minX = math.min(minX, block[1])
        maxX = math.max(maxX, block[1])
        minY = math.min(minY, block[2])
        maxY = math.max(maxY, block[2])
    end
    
    local width = maxX - minX + 1
    local height = maxY - minY + 1
    local offsetX = math.floor((previewSize / BLOCK_SIZE - width) / 2) - minX
    local offsetY = math.floor((previewSize / BLOCK_SIZE - height) / 2) - minY
    
    -- Draw the blocks
    local patternData = self.patterns[nextPieceType]
    for i = 1, #shapeBlocks do
        local block = shapeBlocks[i]
        local blockX = x + (block[1] + offsetX) * BLOCK_SIZE
        local blockY = y + (block[2] + offsetY) * BLOCK_SIZE
        
        -- Fill with pattern
        if patternData then
            gfx.setPattern(patternData)
        else
            gfx.setColor(gfx.kColorBlack)
        end
        gfx.fillRect(blockX, blockY, BLOCK_SIZE, BLOCK_SIZE)
        
        -- Draw outline
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(blockX, blockY, BLOCK_SIZE, BLOCK_SIZE)
    end
end

function Renderer:drawPauseScreen()
    -- Draw pause overlay
    
    -- Semi-transparent overlay effect (using dither pattern)
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
    gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Draw pause text
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    local pauseText = "PAUSED"
    local textWidth = gfx.getTextSize(pauseText)
    local textX = (SCREEN_WIDTH - textWidth) / 2
    local textY = SCREEN_HEIGHT / 2 - 20
    
    -- Draw text background for contrast
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(textX - 10, textY - 5, textWidth + 20, 30)
    
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(pauseText, textX, textY)
    
    -- Draw instruction
    local instructionText = "Press Menu to Resume"
    local instrWidth = gfx.getTextSize(instructionText)
    local instrX = (SCREEN_WIDTH - instrWidth) / 2
    local instrY = textY + 40
    
    gfx.drawText(instructionText, instrX, instrY)
end

function Renderer:drawGameOverScreen(scoreManager)
    -- Draw game over screen with white background for readability
    
    -- Calculate all text positions first
    local gameOverText = "GAME OVER"
    local textWidth = gfx.getTextSize(gameOverText)
    local textX = (SCREEN_WIDTH - textWidth) / 2
    local textY = SCREEN_HEIGHT / 2 - 60
    
    local scoreText = "Final Score: " .. tostring(scoreManager:getScore())
    local scoreWidth = gfx.getTextSize(scoreText)
    local scoreX = (SCREEN_WIDTH - scoreWidth) / 2
    local scoreY = textY + 30
    
    local levelText = "Level: " .. tostring(scoreManager:getLevel())
    local levelWidth = gfx.getTextSize(levelText)
    local levelX = (SCREEN_WIDTH - levelWidth) / 2
    local levelY = scoreY + 25
    
    local linesText = "Lines: " .. tostring(scoreManager:getTotalLines())
    local linesWidth = gfx.getTextSize(linesText)
    local linesX = (SCREEN_WIDTH - linesWidth) / 2
    local linesY = levelY + 25
    
    local restartText = "Press A to Restart"
    local restartWidth = gfx.getTextSize(restartText)
    local restartX = (SCREEN_WIDTH - restartWidth) / 2
    local restartY = linesY + 40
    
    -- Calculate background box dimensions
    local padding = 15
    local boxWidth = math.max(textWidth, scoreWidth, levelWidth, linesWidth, restartWidth) + (padding * 2)
    local boxHeight = (restartY - textY) + 20 + (padding * 2)
    local boxX = (SCREEN_WIDTH - boxWidth) / 2
    local boxY = textY - padding
    
    -- Draw white background box
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(boxX, boxY, boxWidth, boxHeight)
    
    -- Draw black border around box
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawRect(boxX, boxY, boxWidth, boxHeight)
    
    -- Draw text in black
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    gfx.drawText(gameOverText, textX, textY)
    gfx.drawText(scoreText, scoreX, scoreY)
    gfx.drawText(levelText, levelX, levelY)
    gfx.drawText(linesText, linesX, linesY)
    
    -- Draw restart instruction (already calculated above)
    gfx.drawText(restartText, restartX, restartY)
end

function Renderer:drawMenuScreen(scrollOffset)
    -- Draw main menu screen with scrollable content
    scrollOffset = scrollOffset or 0
    
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    -- Draw title
    local titleText = "VIBETRIS"
    local titleWidth = gfx.getTextSize(titleText)
    local titleX = (SCREEN_WIDTH - titleWidth) / 2
    local titleY = 20 - scrollOffset
    
    gfx.drawText(titleText, titleX, titleY)
    
    -- Draw subtitle
    local subtitleText = "for Playdate"
    local subtitleWidth = gfx.getTextSize(subtitleText)
    local subtitleX = (SCREEN_WIDTH - subtitleWidth) / 2
    local subtitleY = titleY + 25
    
    gfx.drawText(subtitleText, subtitleX, subtitleY)
    
    -- Draw start instruction
    local startText = "Press A to Start"
    local startWidth = gfx.getTextSize(startText)
    local startX = (SCREEN_WIDTH - startWidth) / 2
    local startY = subtitleY + 35
    
    gfx.drawText(startText, startX, startY)
    
    -- Draw scroll hint
    local scrollHint = "(Crank to scroll)"
    local scrollWidth = gfx.getTextSize(scrollHint)
    local scrollX = (SCREEN_WIDTH - scrollWidth) / 2
    local scrollY = startY + 20
    
    gfx.drawText(scrollHint, scrollX, scrollY)
    
    -- Draw controls
    local controlsY = scrollY + 30
    local controlsX = 50
    
    gfx.drawText("Controls:", controlsX, controlsY)
    gfx.drawText("Crank or B: Rotate piece", controlsX, controlsY + 20)
    gfx.drawText("D-Pad: Move left/right", controlsX, controlsY + 40)
    gfx.drawText("Down: Soft Drop", controlsX, controlsY + 60)
    gfx.drawText("Up or A: Hard Drop", controlsX, controlsY + 80)
    gfx.drawText("Menu: Pause/Settings", controlsX, controlsY + 100)
end

function Renderer:render(gameManager)
    -- Main render function - draws everything based on game state
    
    if not gameManager then
        return
    end
    
    local state = gameManager:getState()
    
    if state == "start_screen" then
        -- Render start screen
        if gameManager.startScreen then
            gameManager.startScreen:render()
        end
    elseif state == "menu" then
        self:drawMenuScreen(gameManager.menuScrollOffset)
    elseif state == "playing" then
        -- Draw game elements
        local clearAnimation = gameManager:getClearAnimation()
        
        if gameManager.gameState and gameManager.gameState.playfield then
            self:drawPlayfield(gameManager.gameState.playfield, clearAnimation)
        end
        
        -- Draw shadow piece before active piece so it appears behind
        if gameManager.gameState and gameManager.gameState.currentPiece and gameManager.gameState.shadowY then
            self:drawShadowPiece(gameManager.gameState.currentPiece, gameManager.gameState.shadowY)
        end
        
        if gameManager.gameState and gameManager.gameState.currentPiece then
            self:drawPiece(gameManager.gameState.currentPiece)
        end
        
        if gameManager.scoreManager and gameManager.gameState then
            self:drawUI(gameManager.scoreManager, gameManager.gameState)
        end
    elseif state == "paused" then
        -- Draw game elements (frozen)
        if gameManager.gameState and gameManager.gameState.playfield then
            self:drawPlayfield(gameManager.gameState.playfield, nil)
        end
        
        if gameManager.gameState and gameManager.gameState.currentPiece then
            self:drawPiece(gameManager.gameState.currentPiece)
        end
        
        if gameManager.scoreManager and gameManager.gameState then
            self:drawUI(gameManager.scoreManager, gameManager.gameState)
        end
        
        -- Draw pause overlay
        self:drawPauseScreen()
    elseif state == "gameover" then
        -- Draw final game state
        if gameManager.gameState and gameManager.gameState.playfield then
            self:drawPlayfield(gameManager.gameState.playfield, nil)
        end
        
        if gameManager.scoreManager then
            self:drawGameOverScreen(gameManager.scoreManager)
        end
    end
end

-- Export module (compatible with both require and import)
if _G then
    _G.Renderer = Renderer
end
return Renderer

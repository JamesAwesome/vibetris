-- StartScreen: Displays the Vibetris logo on game launch
-- Shows a splash screen with the game logo before transitioning to the menu

-- Support both import (Playdate) and require (testing)
if import then
    import "CoreLibs/graphics"
end

local gfx = playdate and playdate.graphics or {}

local StartScreen = {}
StartScreen.__index = StartScreen

function StartScreen:new()
    local self = setmetatable({}, StartScreen)
    
    -- Try to load logo image
    self.logo = nil
    local success, result = pcall(function()
        return gfx.image.new("images/vibetris-logo")
    end)
    
    if success and result then
        self.logo = result
    else
        -- Logo asset not found, will use text fallback
        print("Logo asset not found, using text fallback")
    end
    
    -- Display state
    self.displayed = false
    self.displayDuration = 5.0 -- seconds
    self.timer = 0
    
    return self
end

function StartScreen:update(dt)
    -- Update the start screen timer
    if self.displayed then
        self.timer = self.timer + dt
        
        -- Check if display duration has elapsed
        if self.timer >= self.displayDuration then
            return true -- Signal to transition to menu
        end
        
        -- Also allow skipping with A button
        if playdate.buttonJustPressed(playdate.kButtonA) then
            return true
        end
    end
    
    return false -- Continue displaying
end

function StartScreen:render()
    -- Render the start screen
    gfx.clear()
    
    if self.logo then
        -- Render logo image centered on screen
        local screenWidth = 400
        local screenHeight = 240
        local logoWidth, logoHeight = self.logo:getSize()
        local x = (screenWidth - logoWidth) / 2
        local y = (screenHeight - logoHeight) / 2
        self.logo:draw(x, y)
    else
        -- Fallback: Render text-based logo
        self:renderTextLogo()
    end
end

function StartScreen:renderTextLogo()
    -- Render a text-based logo as fallback
    local screenWidth = 400
    local screenHeight = 240
    
    -- Use a large font for the title
    local font = gfx.getSystemFont()
    gfx.setFont(font)
    
    -- Draw "VIBETRIS" in large text, centered
    local text = "VIBETRIS"
    local textWidth = gfx.getTextSize(text)
    local x = (screenWidth - textWidth) / 2
    local y = screenHeight / 2 - 20
    
    -- Draw with a simple "bubble" effect using offset shadows
    -- Shadow layers for depth
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(text, x + 2, y + 2)
    gfx.drawText(text, x + 1, y + 1)
    
    -- Main text
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText(text, x, y)
end

function StartScreen:show()
    -- Show the start screen
    self.displayed = true
    self.timer = 0
end

function StartScreen:isDisplayed()
    return self.displayed
end

-- Export module (compatible with both require and import)
if _G then
    _G.StartScreen = StartScreen
end
return StartScreen

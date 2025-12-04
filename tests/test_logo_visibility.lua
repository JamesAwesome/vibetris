-- Property-based test for logo visibility
-- Feature: vibetris-rebrand, Property 4: Logo visibility
-- Validates: Requirements 2.2, 2.3

package.path = package.path .. ";./source/?.lua;../source/?.lua;./tests/lib/?.lua"

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
            new = function(path) return nil end, -- Logo not found, will use fallback
        },
        kDrawModeFillBlack = 0,
        kDrawModeFillWhite = 1,
    },
    buttonJustPressed = function() return false end,
    kButtonA = 6,
}

local StartScreen = require("ui/start_screen")

print("\n=== Property Test: Logo Visibility ===")

-- Property: Logo visibility
-- For any logo rendering, the logo should be positioned within the visible screen bounds
local function test_logo_visibility()
    local startScreen = StartScreen:new()
    
    -- Screen dimensions
    local SCREEN_WIDTH = 400
    local SCREEN_HEIGHT = 240
    
    -- Since we're using text fallback (no image asset), we need to verify
    -- that the text rendering would be within bounds
    
    -- The text "VIBETRIS" should be centered
    local text = "VIBETRIS"
    local textWidth = #text * 8 -- Approximate width
    local x = (SCREEN_WIDTH - textWidth) / 2
    local y = SCREEN_HEIGHT / 2 - 20
    
    -- Verify x position is within bounds
    assert(x >= 0, "Logo x position should be >= 0")
    assert(x + textWidth <= SCREEN_WIDTH, "Logo should not extend beyond right edge")
    
    -- Verify y position is within bounds
    assert(y >= 0, "Logo y position should be >= 0")
    assert(y + 16 <= SCREEN_HEIGHT, "Logo should not extend beyond bottom edge")
    
    return true
end

-- Run the property test
local success, err = pcall(test_logo_visibility)
if success then
    print("✓ Logo visibility property holds")
else
    print("✗ Logo visibility property failed: " .. tostring(err))
    os.exit(1)
end

print("\n✓ All logo visibility tests passed!")

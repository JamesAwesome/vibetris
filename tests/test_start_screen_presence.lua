-- Property Test: Start Screen Presence
-- Feature: vibetris-rebrand, Property 3: Logo presence on start screen
-- Validates: Requirements 2.1, 2.2
--
-- For any game launch sequence, the start screen should display the logo 
-- (either the image asset or fallback text) before transitioning to gameplay.

package.path = package.path .. ";./source/?.lua;../source/?.lua"

-- Mock playdate API
_G.playdate = {
    graphics = {
        clear = function() end,
        image = {
            new = function(path)
                -- Simulate logo loading
                return {
                    getSize = function() return 300, 80 end,
                    draw = function(x, y) end
                }
            end
        },
        getSystemFont = function()
            return {}
        end,
        setFont = function(font) end,
        getTextSize = function(text) return #text * 8 end,
        drawText = function(text, x, y) end,
        setImageDrawMode = function(mode) end,
        kDrawModeFillWhite = 0,
        kDrawModeFillBlack = 1
    },
    buttonJustPressed = function(button) return false end,
    kButtonA = 1
}

local StartScreen = require("ui/start_screen")
local GameManager = require("game/manager")

print("\n=== Property Test: Start Screen Presence ===")
print("Feature: vibetris-rebrand, Property 3: Logo presence on start screen")
print("Validates: Requirements 2.1, 2.2")

-- Property: For any game launch sequence, the start screen should display 
-- the logo before transitioning to gameplay
local function test_start_screen_presence_property()
    local testsPassed = 0
    local totalTests = 100
    
    for i = 1, totalTests do
        -- Create a new start screen instance (simulating game launch)
        local startScreen = StartScreen:new()
        
        -- Show the start screen (simulating game initialization)
        startScreen:show()
        
        -- Verify the start screen is displayed
        assert(startScreen:isDisplayed(), 
            "Start screen should be displayed after game launch")
        
        -- Verify the start screen has either a logo image or will render text fallback
        local hasLogo = startScreen.logo ~= nil
        local hasRenderMethod = type(startScreen.render) == "function"
        local hasTextFallback = type(startScreen.renderTextLogo) == "function"
        
        assert(hasRenderMethod, 
            "Start screen should have a render method")
        assert(hasLogo or hasTextFallback, 
            "Start screen should have either logo image or text fallback")
        
        -- Verify the start screen will eventually transition
        -- (either by timeout or button press)
        local canTransition = false
        
        -- Test timeout transition
        local shouldTransition = startScreen:update(startScreen.displayDuration + 0.1)
        if shouldTransition then
            canTransition = true
        end
        
        assert(canTransition, 
            "Start screen should transition after display duration")
        
        testsPassed = testsPassed + 1
    end
    
    print(string.format("✓ Property verified across %d iterations", totalTests))
    print("  - Start screen displays on every game launch")
    print("  - Logo (image or text) is always present")
    print("  - Transition mechanism works correctly")
    
    return true
end

-- Run the property test
local success, err = pcall(test_start_screen_presence_property)

if success then
    print("\n✓ All property tests passed")
    os.exit(0)
else
    print("\n✗ Property test failed: " .. tostring(err))
    os.exit(1)
end

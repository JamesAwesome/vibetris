-- Unit test for logo loading and fallback
-- Tests logo asset loading and fallback to text rendering

package.path = package.path .. ";./source/?.lua;../source/?.lua"

-- Track what was drawn for verification
local drawnImages = {}
local drawnText = {}

-- Mock Playdate SDK
_G.playdate = {
    graphics = {
        clear = function() end,
        drawRect = function() end,
        fillRect = function() end,
        drawText = function(text, x, y)
            table.insert(drawnText, {text = text, x = x, y = y})
        end,
        getTextSize = function(text) return #text * 8, 16 end,
        setImageDrawMode = function() end,
        setFont = function() end,
        getSystemFont = function() return {} end,
        image = {
            new = function(path)
                -- Simulate logo not found
                return nil
            end,
        },
        kDrawModeFillBlack = 0,
        kDrawModeFillWhite = 1,
    },
    buttonJustPressed = function() return false end,
    kButtonA = 6,
}

local StartScreen = require("ui/start_screen")

print("\n=== Unit Tests: Logo Loading and Fallback ===")

-- Test 1: Logo asset loads correctly (when available)
local function test_logo_asset_loading()
    -- Mock successful logo loading
    _G.playdate.graphics.image.new = function(path)
        if path == "images/vibetris-logo" then
            return {
                getSize = function() return 300, 80 end,
                draw = function(self, x, y)
                    table.insert(drawnImages, {x = x, y = y, width = 300, height = 80})
                end
            }
        end
        return nil
    end
    
    local startScreen = StartScreen:new()
    
    -- Verify logo was loaded
    assert(startScreen.logo ~= nil, "Logo should be loaded when asset is available")
    
    -- Render and verify image is drawn
    drawnImages = {}
    startScreen:render()
    
    assert(#drawnImages == 1, "Logo image should be drawn")
    assert(drawnImages[1].x >= 0, "Logo x position should be valid")
    assert(drawnImages[1].y >= 0, "Logo y position should be valid")
    
    print("✓ Logo asset loads correctly")
    return true
end

-- Test 2: Fallback to text rendering when asset missing
local function test_fallback_to_text()
    -- Mock logo not found
    _G.playdate.graphics.image.new = function(path)
        return nil
    end
    
    local startScreen = StartScreen:new()
    
    -- Verify logo is nil (not loaded)
    assert(startScreen.logo == nil, "Logo should be nil when asset is missing")
    
    -- Render and verify text is drawn
    drawnText = {}
    startScreen:render()
    
    -- Should have drawn "VIBETRIS" text
    local foundVibetris = false
    for i = 1, #drawnText do
        if drawnText[i].text == "VIBETRIS" then
            foundVibetris = true
            break
        end
    end
    
    assert(foundVibetris, "Should render 'VIBETRIS' text as fallback")
    
    print("✓ Fallback to text rendering when asset missing")
    return true
end

-- Test 3: Start screen displays on initialization
local function test_start_screen_display()
    local startScreen = StartScreen:new()
    
    -- Show the start screen
    startScreen:show()
    
    assert(startScreen:isDisplayed(), "Start screen should be displayed after show()")
    assert(startScreen.timer == 0, "Timer should start at 0")
    
    print("✓ Start screen displays on initialization")
    return true
end

-- Test 4: Start screen transitions after timeout
local function test_start_screen_timeout()
    local startScreen = StartScreen:new()
    startScreen:show()
    
    -- Update for less than display duration
    local shouldTransition = startScreen:update(1.0)
    assert(not shouldTransition, "Should not transition before timeout")
    
    -- Update past display duration
    shouldTransition = startScreen:update(1.5)
    assert(shouldTransition, "Should transition after timeout")
    
    print("✓ Start screen transitions after timeout")
    return true
end

-- Test 5: Start screen can be skipped with A button
local function test_start_screen_skip()
    -- Mock A button press
    _G.playdate.buttonJustPressed = function(button)
        return button == _G.playdate.kButtonA
    end
    
    local startScreen = StartScreen:new()
    startScreen:show()
    
    -- Update with A button pressed
    local shouldTransition = startScreen:update(0.1)
    assert(shouldTransition, "Should transition immediately when A button is pressed")
    
    print("✓ Start screen can be skipped with A button")
    return true
end

-- Run all tests
local all_passed = true
all_passed = all_passed and test_logo_asset_loading()
all_passed = all_passed and test_fallback_to_text()
all_passed = all_passed and test_start_screen_display()
all_passed = all_passed and test_start_screen_timeout()
all_passed = all_passed and test_start_screen_skip()

if all_passed then
    print("\n✓ All logo loading and fallback tests passed!")
else
    print("\n✗ Some logo loading tests failed!")
    os.exit(1)
end

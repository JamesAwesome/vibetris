-- Feature: vibetris-rebrand, Property 2: Configuration consistency
-- **Validates: Requirements 1.3, 1.5**
-- For any configuration file (pdxinfo, rockspec), all references to the game name 
-- should use "Vibetris" or "vibetris" consistently.

local lqc = require("lib/lqc")

-- Helper function to read file contents
local function read_file(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Helper function to check if a string contains "tetris" (case-insensitive)
-- but not as part of "vibetris"
local function contains_old_branding(text)
    if not text then return false end
    
    -- Convert to lowercase for case-insensitive search
    local lower_text = text:lower()
    
    -- Look for "tetris" that is NOT part of "vibetris"
    -- We'll check for word boundaries or common separators
    local patterns = {
        "^tetris",           -- starts with tetris
        "tetris$",           -- ends with tetris
        "[%s%-_/]tetris",    -- tetris after whitespace or separator
        "tetris[%s%-_/]",    -- tetris before whitespace or separator
        "\"tetris\"",        -- tetris in quotes
        "'tetris'",          -- tetris in single quotes
        "=tetris",           -- tetris after equals
        "tetris=",           -- tetris before equals
    }
    
    for _, pattern in ipairs(patterns) do
        if lower_text:match(pattern) then
            return true
        end
    end
    
    return false
end

-- Property: pdxinfo uses Vibetris branding
local prop_pdxinfo = lqc.property("pdxinfo uses Vibetris branding consistently",
    lqc.forall(
        {},
        function()
            local content = read_file("pdxinfo")
            if not content then
                error("Could not read pdxinfo file")
            end
            
            -- Check that it contains "Vibetris"
            local has_vibetris = content:match("Vibetris") or content:match("vibetris")
            
            -- Check that it doesn't contain old "Tetris" branding
            local has_old_branding = contains_old_branding(content)
            
            return has_vibetris and not has_old_branding
        end
    )
)

-- Property: rockspec uses vibetris branding
local prop_rockspec = lqc.property("rockspec uses vibetris branding consistently",
    lqc.forall(
        {},
        function()
            local content = read_file("vibetris-dev-1.rockspec")
            if not content then
                error("Could not read vibetris-dev-1.rockspec file")
            end
            
            -- Check that it contains "vibetris"
            local has_vibetris = content:match("vibetris") or content:match("Vibetris")
            
            -- Check that it doesn't contain old "tetris" branding (excluding "Tetris mechanics" which is acceptable)
            -- We need to be careful here - "Tetris mechanics" is a technical term
            local lines = {}
            for line in content:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            
            local has_invalid_branding = false
            for _, line in ipairs(lines) do
                -- Skip lines that mention "Tetris mechanics" or similar technical terms
                if not line:match("Tetris mechanics") and not line:match("Traditional Tetris") then
                    if contains_old_branding(line) then
                        has_invalid_branding = true
                        break
                    end
                end
            end
            
            return has_vibetris and not has_invalid_branding
        end
    )
)

-- Property: package name is vibetris
local prop_package_name = lqc.property("rockspec package name is vibetris",
    lqc.forall(
        {},
        function()
            local content = read_file("vibetris-dev-1.rockspec")
            if not content then
                error("Could not read vibetris-dev-1.rockspec file")
            end
            
            -- Check that package = "vibetris"
            return content:match('package%s*=%s*"vibetris"') ~= nil
        end
    )
)

-- Property: bundleID uses vibetris
local prop_bundle_id = lqc.property("pdxinfo bundleID uses vibetris",
    lqc.forall(
        {},
        function()
            local content = read_file("pdxinfo")
            if not content then
                error("Could not read pdxinfo file")
            end
            
            -- Check that bundleID contains vibetris
            return content:match("bundleID=.*vibetris") ~= nil
        end
    )
)

-- Add tests to the suite
lqc.addTest(prop_pdxinfo)
lqc.addTest(prop_rockspec)
lqc.addTest(prop_package_name)
lqc.addTest(prop_bundle_id)

-- Feature: vibetris-rebrand, Property 6: Documentation consistency
-- **Validates: Requirements 1.3**
-- For any documentation file, references to the game should use "Vibetris" 
-- except where historical context requires "Tetris".

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
        "playdate tetris",   -- "playdate tetris" phrase
        "tetris for",        -- "tetris for" phrase
    }
    
    for _, pattern in ipairs(patterns) do
        if lower_text:match(pattern) then
            return true
        end
    end
    
    return false
end

-- Helper function to check if line contains acceptable technical terms
local function is_acceptable_context(line)
    local lower_line = line:lower()
    -- Allow "tetris mechanics", "traditional tetris", "tetromino" (which contains "tetro")
    return lower_line:match("tetris mechanics") or 
           lower_line:match("traditional tetris") or
           lower_line:match("classic tetris") or
           lower_line:match("standard tetris")
end

-- Property: README.md uses Vibetris branding
local prop_readme = lqc.property("README.md uses Vibetris branding consistently",
    lqc.forall(
        {},
        function()
            local content = read_file("README.md")
            if not content then
                error("Could not read README.md file")
            end
            
            -- Check that it contains "Vibetris"
            local has_vibetris = content:match("Vibetris") or content:match("vibetris")
            
            -- Check that it doesn't contain old "Tetris" branding in inappropriate contexts
            local lines = {}
            for line in content:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            
            local has_invalid_branding = false
            for _, line in ipairs(lines) do
                if not is_acceptable_context(line) then
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

-- Property: PROJECT_STRUCTURE.md uses Vibetris branding
local prop_project_structure = lqc.property("PROJECT_STRUCTURE.md uses Vibetris branding consistently",
    lqc.forall(
        {},
        function()
            local content = read_file("PROJECT_STRUCTURE.md")
            if not content then
                error("Could not read PROJECT_STRUCTURE.md file")
            end
            
            -- Check that it contains "Vibetris" or "vibetris"
            local has_vibetris = content:match("Vibetris") or content:match("vibetris")
            
            -- Check that it doesn't contain old "Tetris" branding in inappropriate contexts
            local lines = {}
            for line in content:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            
            local has_invalid_branding = false
            for _, line in ipairs(lines) do
                if not is_acceptable_context(line) then
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

-- Property: Documentation files reference correct spec directory
local prop_spec_directory = lqc.property("Documentation references correct spec directory",
    lqc.forall(
        {},
        function()
            local readme = read_file("README.md")
            local project_structure = read_file("PROJECT_STRUCTURE.md")
            
            if not readme or not project_structure then
                error("Could not read documentation files")
            end
            
            -- Check that documentation references the vibetris spec directory
            -- README should have links to .kiro/specs/vibetris
            local readme_has_correct_path = readme:match("%.kiro/specs/vibetris") ~= nil
            
            -- PROJECT_STRUCTURE should show vibetris directory in the tree structure
            -- It can be either ".kiro/specs/vibetris" or just "vibetris/" in the tree
            local structure_has_correct_path = project_structure:match("specs/") ~= nil and 
                                               project_structure:match("vibetris/") ~= nil
            
            -- Check that they don't reference the old playdate-tetris directory
            local readme_has_old_path = readme:match("%.kiro/specs/playdate%-tetris") ~= nil
            local structure_has_old_path = project_structure:match("playdate%-tetris/") ~= nil
            
            return readme_has_correct_path and structure_has_correct_path and 
                   not readme_has_old_path and not structure_has_old_path
        end
    )
)

-- Property: README title uses Vibetris
local prop_readme_title = lqc.property("README title uses Vibetris",
    lqc.forall(
        {},
        function()
            local content = read_file("README.md")
            if not content then
                error("Could not read README.md file")
            end
            
            -- Check that the first heading (title) contains "Vibetris"
            local first_line = content:match("^[^\n]+")
            return first_line and first_line:match("Vibetris") ~= nil
        end
    )
)

-- Property: PROJECT_STRUCTURE title uses Vibetris
local prop_structure_title = lqc.property("PROJECT_STRUCTURE title uses Vibetris",
    lqc.forall(
        {},
        function()
            local content = read_file("PROJECT_STRUCTURE.md")
            if not content then
                error("Could not read PROJECT_STRUCTURE.md file")
            end
            
            -- Check that the first heading (title) contains "Vibetris"
            local first_line = content:match("^[^\n]+")
            return first_line and first_line:match("Vibetris") ~= nil
        end
    )
)

-- Property: Build commands reference Vibetris.pdx
local prop_build_commands = lqc.property("Build commands reference Vibetris.pdx",
    lqc.forall(
        {},
        function()
            local readme = read_file("README.md")
            if not readme then
                error("Could not read README.md file")
            end
            
            -- Check that build commands use Vibetris.pdx
            local has_vibetris_pdx = readme:match("Vibetris%.pdx") ~= nil
            
            -- Check that they don't reference Tetris.pdx
            local has_tetris_pdx = readme:match("Tetris%.pdx") ~= nil
            
            return has_vibetris_pdx and not has_tetris_pdx
        end
    )
)

-- Add tests to the suite
lqc.addTest(prop_readme)
lqc.addTest(prop_project_structure)
lqc.addTest(prop_spec_directory)
lqc.addTest(prop_readme_title)
lqc.addTest(prop_structure_title)
lqc.addTest(prop_build_commands)

-- Property-based test for row collapse after line clear
-- Feature: vibetris, Property 14: Rows collapse after line clear
-- Validates: Requirements 5.2

local lqc = require("lib/lqc")
local game = require("game/init")

-- Custom generator for playfield states with complete lines
local Generator = {}
Generator.__index = Generator

function Generator:new(generate_fn)
    local gen = {
        generate = generate_fn
    }
    setmetatable(gen, Generator)
    return gen
end

local function generatePlayfieldWithTrackedLines()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        
        -- Create a playfield with some complete lines and track what's above them
        local numCompleteLines = math.random(1, 3)
        local completeLineIndices = {}
        
        -- Select random rows to make complete (not at the very top)
        for i = 1, numCompleteLines do
            local lineY = math.random(5, 15) -- Middle section
            while completeLineIndices[lineY] do
                lineY = math.random(5, 15)
            end
            table.insert(completeLineIndices, lineY)
        end
        
        table.sort(completeLineIndices)
        
        -- Fill the playfield with a pattern we can track
        for y = 1, 20 do
            local isCompleteLine = false
            for _, completeY in ipairs(completeLineIndices) do
                if y == completeY then
                    isCompleteLine = true
                    break
                end
            end
            
            if isCompleteLine then
                -- Make this line complete
                for x = 1, 10 do
                    playfield.grid[y][x] = "C" -- "C" for complete line
                end
            else
                -- Create a recognizable pattern (use the y coordinate as the value)
                -- This helps us track which rows moved where
                for x = 1, 10 do
                    if math.random() > 0.3 then -- 70% chance of block
                        playfield.grid[y][x] = tostring(y) -- Store row number as identifier
                    end
                end
            end
        end
        
        return {playfield = playfield, completeLineIndices = completeLineIndices}
    end)
end

-- Property 14: Rows collapse after line clear
-- For any line clear operation, all rows above the cleared row(s) should move 
-- downward by the number of rows cleared
local prop_rows_collapse = lqc.property("rows collapse after line clear",
    lqc.forall(
        {generatePlayfieldWithTrackedLines()},
        function(data)
            local playfield = data.playfield
            local completeLineIndices = data.completeLineIndices
            
            -- Store the entire grid state before clearing
            local gridBefore = {}
            for y = 1, 20 do
                gridBefore[y] = {}
                for x = 1, 10 do
                    gridBefore[y][x] = playfield.grid[y][x]
                end
            end
            
            -- Detect and clear the complete lines
            local detectedLines = playfield:checkLines()
            local numLinesCleared = #detectedLines
            
            if numLinesCleared == 0 then
                -- No lines to clear, property is trivially true
                return true
            end
            
            playfield:clearLines(detectedLines)
            
            -- Verify new empty rows were added at the top
            for y = 1, numLinesCleared do
                local isEmpty = true
                for x = 1, 10 do
                    if playfield.grid[y][x] ~= nil then
                        isEmpty = false
                        break
                    end
                end
                
                if not isEmpty then
                    return false, string.format("Row %d at top should be empty after clearing %d lines", y, numLinesCleared)
                end
            end
            
            -- Verify the grid still has correct height
            if #playfield.grid ~= 20 then
                return false, string.format("Playfield height is %d, expected 20", #playfield.grid)
            end
            
            -- Verify rows collapsed: check that non-cleared rows moved down correctly
            -- Build a list of non-cleared rows from the original grid
            local nonClearedRows = {}
            for y = 1, 20 do
                local wasCleared = false
                for _, clearedY in ipairs(detectedLines) do
                    if y == clearedY then
                        wasCleared = true
                        break
                    end
                end
                
                if not wasCleared then
                    table.insert(nonClearedRows, gridBefore[y])
                end
            end
            
            -- After clearing, the bottom rows should match the non-cleared rows
            -- (with new empty rows at the top)
            local startY = numLinesCleared + 1
            for i = 1, #nonClearedRows do
                local expectedY = startY + i - 1
                local expectedRow = nonClearedRows[i]
                
                for x = 1, 10 do
                    if playfield.grid[expectedY][x] ~= expectedRow[x] then
                        return false, string.format("Row %d does not match expected content after collapse", expectedY)
                    end
                end
            end
            
            -- Verify no complete lines remain
            local remainingCompleteLines = playfield:checkLines()
            if #remainingCompleteLines > 0 then
                return false, string.format("Found %d complete lines remaining after clear", #remainingCompleteLines)
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_rows_collapse)

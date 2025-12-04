-- Property-based test for line clearing
-- Feature: vibetris, Property 13: Complete rows are cleared
-- Validates: Requirements 5.1

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

local function generatePlayfieldWithCompleteLines()
    return Generator:new(function()
        local playfield = game.Playfield:new(10, 20)
        
        -- Randomly decide how many complete lines to create (0-4)
        local numCompleteLines = math.random(0, 4)
        local completeLineIndices = {}
        
        -- Select random rows to make complete
        for i = 1, numCompleteLines do
            local lineY = math.random(1, 20)
            -- Avoid duplicates
            while completeLineIndices[lineY] do
                lineY = math.random(1, 20)
            end
            completeLineIndices[lineY] = true
        end
        
        -- Fill the playfield
        for y = 1, 20 do
            if completeLineIndices[y] then
                -- Make this line complete
                for x = 1, 10 do
                    playfield.grid[y][x] = "I" -- Use any piece type
                end
            else
                -- Make this line incomplete (randomly fill some cells)
                local numBlocks = math.random(0, 9) -- 0-9 blocks (not 10, so incomplete)
                for i = 1, numBlocks do
                    local x = math.random(1, 10)
                    playfield.grid[y][x] = "I"
                end
            end
        end
        
        return {playfield = playfield, expectedCompleteLines = completeLineIndices}
    end)
end

-- Property 13: Complete rows are cleared
-- For any playfield state where a horizontal row is completely filled with blocks,
-- that row should be removed from the grid
local prop_complete_rows_cleared = lqc.property("complete rows are cleared",
    lqc.forall(
        {generatePlayfieldWithCompleteLines()},
        function(data)
            local playfield = data.playfield
            local expectedCompleteLines = data.expectedCompleteLines
            
            -- Check which lines are detected as complete
            local detectedLines = playfield:checkLines()
            
            -- Convert detected lines to a set for easy comparison
            local detectedSet = {}
            for i = 1, #detectedLines do
                detectedSet[detectedLines[i]] = true
            end
            
            -- Verify all expected complete lines are detected
            for lineY, _ in pairs(expectedCompleteLines) do
                if not detectedSet[lineY] then
                    return false, string.format("Complete line at y=%d was not detected", lineY)
                end
            end
            
            -- Verify no incomplete lines are detected as complete
            for i = 1, #detectedLines do
                if not expectedCompleteLines[detectedLines[i]] then
                    return false, string.format("Incomplete line at y=%d was incorrectly detected as complete", detectedLines[i])
                end
            end
            
            -- Now clear the lines
            local lineCountBefore = #detectedLines
            playfield:clearLines(detectedLines)
            
            -- After clearing, verify those lines no longer exist as complete
            local linesAfterClear = playfield:checkLines()
            
            -- The lines that were cleared should not appear in the new check
            for i = 1, #detectedLines do
                for j = 1, #linesAfterClear do
                    if detectedLines[i] == linesAfterClear[j] then
                        return false, string.format("Line y=%d still appears as complete after clearing", detectedLines[i])
                    end
                end
            end
            
            -- Verify the grid still has the correct height
            if #playfield.grid ~= 20 then
                return false, string.format("Playfield height is %d after clearing, expected 20", #playfield.grid)
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_complete_rows_cleared)

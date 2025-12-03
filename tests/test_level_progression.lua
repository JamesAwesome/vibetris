-- Property-based test for level progression
-- Feature: playdate-tetris, Property 17: Level increases with line threshold
-- Validates: Requirements 6.1

local lqc = require("lib/lqc")
local game = require("game/init")

-- Property 17: Level increases with line threshold
-- For any game state, when total lines cleared reaches a multiple of 10,
-- the level should increment by 1
local prop_level_progression = lqc.property("level increases with line threshold",
    lqc.forall(
        {
            lqc.generators.int(0, 100)  -- Total lines to clear (0-100)
        },
        function(totalLines)
            local scoreManager = game.ScoreManager:new()
            
            -- Clear lines in random batches
            local linesCleared = 0
            while linesCleared < totalLines do
                local batch = math.min(math.random(1, 4), totalLines - linesCleared)
                scoreManager:addLines(batch)
                linesCleared = linesCleared + batch
            end
            
            -- Calculate expected level
            -- Level = floor(totalLines / 10) + 1
            local expectedLevel = math.floor(totalLines / 10) + 1
            local actualLevel = scoreManager:getLevel()
            
            if actualLevel ~= expectedLevel then
                return false, string.format(
                    "After clearing %d lines, expected level %d but got %d",
                    totalLines, expectedLevel, actualLevel
                )
            end
            
            -- Verify total lines cleared is correct
            if scoreManager:getTotalLines() ~= totalLines then
                return false, string.format(
                    "Expected %d total lines cleared, got %d",
                    totalLines, scoreManager:getTotalLines()
                )
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_level_progression)

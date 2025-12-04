-- Property-based test for score updates
-- Feature: vibetris, Property 16: Line clears update score
-- Validates: Requirements 5.4

local lqc = require("lib/lqc")
local game = require("game/init")

-- Property 16: Line clears update score
-- For any line clear operation clearing N lines, the score should increase
-- by a deterministic amount based on N and the current level
local prop_line_clears_update_score = lqc.property("line clears update score",
    lqc.forall(
        {
            lqc.generators.int(1, 4),  -- Number of lines cleared (1-4)
            lqc.generators.int(1, 20)  -- Current level (1-20)
        },
        function(linesCleared, initialLevel)
            local scoreManager = game.ScoreManager:new()
            
            -- Set up initial level by clearing appropriate number of lines
            -- Level = floor(totalLines / 10) + 1
            -- So to get to level L, we need (L-1) * 10 lines
            local linesToReachLevel = (initialLevel - 1) * 10
            if linesToReachLevel > 0 then
                -- Clear lines in batches to reach desired level
                while linesToReachLevel > 0 do
                    local batch = math.min(4, linesToReachLevel)
                    scoreManager:addLines(batch)
                    linesToReachLevel = linesToReachLevel - batch
                end
            end
            
            -- Verify we're at the expected level
            if scoreManager:getLevel() ~= initialLevel then
                return false, string.format("Failed to set up level %d, got %d", initialLevel, scoreManager:getLevel())
            end
            
            -- Record score before clearing lines
            local scoreBefore = scoreManager:getScore()
            
            -- Clear the specified number of lines
            scoreManager:addLines(linesCleared)
            
            -- Record score after
            local scoreAfter = scoreManager:getScore()
            
            -- Calculate expected score increase
            local scoreValues = {
                [1] = 40,
                [2] = 100,
                [3] = 300,
                [4] = 1200,
            }
            local expectedIncrease = scoreValues[linesCleared] * initialLevel
            local actualIncrease = scoreAfter - scoreBefore
            
            -- Verify score increased by the expected amount
            if actualIncrease ~= expectedIncrease then
                return false, string.format(
                    "Expected score increase of %d (lines=%d, level=%d), got %d",
                    expectedIncrease, linesCleared, initialLevel, actualIncrease
                )
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_line_clears_update_score)

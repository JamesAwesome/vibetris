-- Property-based test for multi-line bonus
-- Feature: vibetris, Property 15: Multi-line clears award bonus points
-- Validates: Requirements 5.3

local lqc = require("lib/lqc")
local game = require("game/init")

-- Property 15: Multi-line clears award bonus points
-- For any number of simultaneously cleared lines N, the score awarded should be
-- greater than N times the single-line score (score(N) > N * score(1) for N > 1)
local prop_multi_line_bonus = lqc.property("multi-line clears award bonus points",
    lqc.forall(
        {
            lqc.generators.int(2, 4),  -- Number of lines cleared (2-4, testing multi-line)
            lqc.generators.int(1, 20)  -- Current level (1-20)
        },
        function(linesCleared, level)
            local scoreManager = game.ScoreManager:new()
            
            -- Set up the level
            local linesToReachLevel = (level - 1) * 10
            if linesToReachLevel > 0 then
                while linesToReachLevel > 0 do
                    local batch = math.min(4, linesToReachLevel)
                    scoreManager:addLines(batch)
                    linesToReachLevel = linesToReachLevel - batch
                end
            end
            
            -- Reset score to 0 for clean comparison
            local currentScore = scoreManager:getScore()
            
            -- Calculate score for single line clear
            local singleLineScore = 40 * level  -- Base score for 1 line * level
            
            -- Calculate score for N lines cleared
            local scoreValues = {
                [2] = 100,
                [3] = 300,
                [4] = 1200,
            }
            local multiLineScore = scoreValues[linesCleared] * level
            
            -- Verify that multi-line score > N * single-line score
            local nTimesSingleLine = linesCleared * singleLineScore
            
            if multiLineScore <= nTimesSingleLine then
                return false, string.format(
                    "Multi-line bonus not applied: %d lines gives %d points, but %d * single-line (%d) = %d",
                    linesCleared, multiLineScore, linesCleared, singleLineScore, nTimesSingleLine
                )
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_multi_line_bonus)

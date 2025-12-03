-- Property-based test for fall speed scaling
-- Feature: playdate-tetris, Property 18: Higher levels have faster fall speed
-- Validates: Requirements 6.2

local lqc = require("lib/lqc")
local game = require("game/init")

-- Property 18: Higher levels have faster fall speed
-- For any two levels L1 and L2 where L2 > L1, the fall interval at L2
-- should be less than or equal to the fall interval at L1
-- (Less than when not at minimum cap, equal when both at cap)
local prop_fall_speed_scaling = lqc.property("higher levels have faster fall speed",
    lqc.forall(
        {
            lqc.generators.int(1, 19),  -- Level 1 (L1)
            lqc.generators.int(1, 10)   -- Delta to add to L1 to get L2
        },
        function(level1, delta)
            local level2 = level1 + delta
            
            -- Create two score managers at different levels
            local scoreManager1 = game.ScoreManager:new()
            local scoreManager2 = game.ScoreManager:new()
            
            -- Set up level 1
            local linesToReachLevel1 = (level1 - 1) * 10
            if linesToReachLevel1 > 0 then
                while linesToReachLevel1 > 0 do
                    local batch = math.min(4, linesToReachLevel1)
                    scoreManager1:addLines(batch)
                    linesToReachLevel1 = linesToReachLevel1 - batch
                end
            end
            
            -- Set up level 2
            local linesToReachLevel2 = (level2 - 1) * 10
            if linesToReachLevel2 > 0 then
                while linesToReachLevel2 > 0 do
                    local batch = math.min(4, linesToReachLevel2)
                    scoreManager2:addLines(batch)
                    linesToReachLevel2 = linesToReachLevel2 - batch
                end
            end
            
            -- Get fall speeds (intervals)
            local fallInterval1 = scoreManager1:getFallSpeed()
            local fallInterval2 = scoreManager2:getFallSpeed()
            
            -- Verify L2 > L1
            if scoreManager2:getLevel() <= scoreManager1:getLevel() then
                return false, string.format(
                    "Level setup failed: L2 (%d) should be > L1 (%d)",
                    scoreManager2:getLevel(), scoreManager1:getLevel()
                )
            end
            
            -- Verify fall interval at L2 <= fall interval at L1
            -- (lower interval = faster falling, equal when both at minimum cap)
            if fallInterval2 > fallInterval1 then
                return false, string.format(
                    "Fall speed not increasing: Level %d has interval %.3f, Level %d has interval %.3f (should be less or equal)",
                    scoreManager1:getLevel(), fallInterval1,
                    scoreManager2:getLevel(), fallInterval2
                )
            end
            
            return true
        end
    )
)

-- Add property test to suite
lqc.addTest(prop_fall_speed_scaling)

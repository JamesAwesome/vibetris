-- ScoreManager: Tracks score, level, and lines cleared
-- Handles score calculation for line clears with multi-line bonuses
-- Manages level progression and fall speed calculation

local ScoreManager = {}
ScoreManager.__index = ScoreManager

-- Scoring constants (based on classic Tetris scoring)
local SCORE_VALUES = {
    [1] = 40,   -- Single line
    [2] = 100,  -- Double
    [3] = 300,  -- Triple
    [4] = 1200, -- Tetris
}

-- Level progression: every 10 lines cleared increases level
local LINES_PER_LEVEL = 10

-- Fall speed calculation: base interval decreases with level
-- Formula: fallInterval = max(0.1, 1.0 - (level - 1) * 0.05)
local BASE_FALL_INTERVAL = 1.0
local FALL_SPEED_DECREASE = 0.05
local MIN_FALL_INTERVAL = 0.1

function ScoreManager:new()
    local self = setmetatable({}, ScoreManager)
    self.score = 0
    self.level = 1
    self.totalLinesCleared = 0
    return self
end

function ScoreManager:addLines(count)
    -- Add cleared lines and update score and level
    -- count: number of lines cleared simultaneously (1-4)
    
    if count < 1 or count > 4 then
        return -- Invalid line count
    end
    
    -- Update total lines cleared
    self.totalLinesCleared = self.totalLinesCleared + count
    
    -- Calculate score based on lines cleared and current level
    local baseScore = SCORE_VALUES[count] or 0
    local scoreToAdd = baseScore * self.level
    self.score = self.score + scoreToAdd
    
    -- Update level based on total lines cleared
    local newLevel = math.floor(self.totalLinesCleared / LINES_PER_LEVEL) + 1
    self.level = newLevel
end

function ScoreManager:getScore()
    return self.score
end

function ScoreManager:getLevel()
    return self.level
end

function ScoreManager:getTotalLines()
    return self.totalLinesCleared
end

function ScoreManager:getFallSpeed()
    -- Calculate fall interval (time between automatic downward movements)
    -- Lower interval = faster falling
    local interval = BASE_FALL_INTERVAL - (self.level - 1) * FALL_SPEED_DECREASE
    return math.max(MIN_FALL_INTERVAL, interval)
end

-- Export module (make globally available for Playdate import system)
_G.ScoreManager = ScoreManager

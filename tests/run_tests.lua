#!/usr/bin/env lua

-- Test runner for Playdate Tetris
-- This script runs all property-based tests

-- Add tests directory to package path
package.path = package.path .. ";./tests/?.lua;./tests/lib/?.lua;./source/?.lua;../source/?.lua"

-- Load the testing library
local lqc = require("lib/lqc")

-- Mock Playdate SDK for testing
-- This allows tests to run outside the Playdate environment
_G.playdate = {
    graphics = {
        clear = function() end,
        drawRect = function() end,
        fillRect = function() end,
        drawText = function() end,
    },
    timer = {
        updateTimers = function() end,
    },
    getCrankPosition = function() return 0 end,
    getCrankChange = function() return 0 end,
    buttonIsPressed = function() return false end,
    buttonJustPressed = function() return false end,
    drawFPS = function() end,
}

-- Import test files
-- Test files will be added here as they are created
require("test_framework")

-- Unit tests
local unit_tests_passed = require("test_tetromino_shapes")

-- Property-based tests
require("test_piece_spawning")
require("test_collision_detection")
require("test_horizontal_movement")
require("test_rotation")
require("test_wall_kicks")
require("test_failed_rotation")
require("test_automatic_descent")
require("test_lock_delay")
require("test_spawn_after_lock")
require("test_game_over")
require("test_line_clearing")
require("test_row_collapse")

print("Playdate Tetris - Property-Based Test Suite")
print("============================================")

-- Run all tests
local results, all_passed = lqc.runTests()

-- Exit with appropriate code
if all_passed then
    print("\n✓ All tests passed!")
    os.exit(0)
else
    print("\n✗ Some tests failed!")
    os.exit(1)
end

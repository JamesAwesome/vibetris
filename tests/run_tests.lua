#!/usr/bin/env lua

-- Test runner for Playdate Tetris
-- This script runs all property-based tests

-- Add luarocks paths
package.path = package.path .. ";/Users/james/.luarocks/share/lua/5.4/?.lua;/Users/james/.luarocks/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";/Users/james/.luarocks/lib/lua/5.4/?.so"

-- Start code coverage tracking
require("luacov")

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
require("test_menu_scrolling")
require("test_a_button_hard_drop")
require("test_a_button_restart")
require("test_game_manager")
require("test_shadow_calculation")
require("test_logo_loading")
require("test_logo_visibility")

-- Property-based tests
require("test_config_consistency")
require("test_documentation_consistency")
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
require("test_score_updates")
require("test_multi_line_bonus")
require("test_level_progression")
require("test_fall_speed_scaling")
require("test_soft_drop")
require("test_hard_drop")
require("test_pause_behavior")
require("test_pause_round_trip")
require("test_next_piece_availability")
require("test_b_button_rotation")
require("test_shadow_accuracy")

print("Playdate Tetris - Property-Based Test Suite")
print("============================================")

-- Run all tests
local results, all_passed = lqc.runTests()

-- Generate coverage report
print("\n=== Generating Coverage Report ===")
local luacov_runner = require("luacov.runner")
luacov_runner.shutdown()

-- Run the reporter to generate human-readable report
os.execute("luacov")

-- Display coverage summary
print("\nCoverage report generated: luacov.report.out")
print("Run 'cat luacov.report.out' to view detailed coverage")

-- Try to display a summary
local report_file = io.open("luacov.report.out", "r")
if report_file then
    print("\n=== Coverage Summary ===")
    local in_summary = false
    local summary_lines = {}
    
    for line in report_file:lines() do
        -- Look for the summary section at the end
        if line:match("^Summary$") then
            in_summary = true
            table.insert(summary_lines, line)
        elseif in_summary then
            table.insert(summary_lines, line)
        end
    end
    
    -- Print the summary section
    for _, line in ipairs(summary_lines) do
        print(line)
    end
    
    report_file:close()
    
    -- If no summary found, show a simple message
    if #summary_lines == 0 then
        print("Summary section not found in report. View full report with: cat luacov.report.out")
    end
end

-- Exit with appropriate code
if all_passed then
    print("\n✓ All tests passed!")
    os.exit(0)
else
    print("\n✗ Some tests failed!")
    os.exit(1)
end

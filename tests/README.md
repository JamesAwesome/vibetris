# Playdate Tetris Test Suite

This directory contains property-based tests and unit tests for the Playdate Tetris implementation.

## Prerequisites

### Installing Lua and LuaRocks

The test suite requires Lua and LuaRocks (Lua package manager).

**On macOS (using Homebrew):**

```bash
# Install Lua
brew install lua

# Install LuaRocks
brew install luarocks
```

**On Linux:**

```bash
# Ubuntu/Debian
sudo apt-get install lua5.4 luarocks

# Fedora
sudo dnf install lua luarocks
```

### Installing Dependencies

You can install all testing dependencies using the rockspec:

```bash
luarocks install --only-deps playdate-tetris-dev-1.rockspec
```

Or install LuaCov manually:

```bash
luarocks install luacov
```

Verify installation:

```bash
luarocks list | grep luacov
```

## Running Tests

### Option 1: Direct execution

To run all tests with code coverage:

```bash
lua tests/run_tests.lua
```

Or make it executable and run directly:

```bash
chmod +x tests/run_tests.lua
./tests/run_tests.lua
```

### Option 2: Via LuaRocks

If you've installed the rockspec:

```bash
luarocks test playdate-tetris-dev-1.rockspec
```

The test runner will automatically:
- Run all unit tests
- Run all property-based tests (100 iterations each)
- Generate code coverage reports
- Display a coverage summary

## Viewing Coverage Reports

After running tests, view the detailed coverage report:

```bash
cat luacov.report.out
```

Or use the helper script:

```bash
./view_coverage.sh
```

## Test Framework

The project uses `lua-quickcheck` (lqc), a lightweight property-based testing library located in `tests/lib/lqc.lua`.

### Writing Property Tests

Property tests verify that certain properties hold true across many randomly generated inputs.

Example:

```lua
local lqc = require("lqc")

-- Define a property
local prop = lqc.property("my property name", 
    lqc.forall(
        {lqc.generators.int(0, 100)},  -- generators for test inputs
        function(x)
            -- Test logic - return true if property holds
            return x >= 0 and x <= 100
        end
    )
)

-- Add to test suite
lqc.addTest(prop)
```

### Available Generators

- `lqc.generators.int(min, max)` - Random integers
- `lqc.generators.boolean()` - Random booleans
- `lqc.generators.choose(options)` - Random choice from array
- `lqc.generators.string(min_len, max_len)` - Random strings
- `lqc.generators.array(element_gen, min_len, max_len)` - Random arrays

### Test Configuration

Each property test runs 100 iterations by default. This can be configured in the Property object.

## Test Types

### Unit Tests
- `test_tetromino_shapes.lua` - Tetromino shape validation
- `test_menu_scrolling.lua` - Menu scrolling behavior
- `test_a_button_hard_drop.lua` - A button hard drop functionality
- `test_game_manager.lua` - GameManager integration tests

### Property-Based Tests
- `test_piece_spawning.lua` - Piece spawn location
- `test_collision_detection.lua` - Collision validation
- `test_horizontal_movement.lua` - Left/right movement
- `test_rotation.lua` - Crank rotation
- `test_b_button_rotation.lua` - B button rotation
- `test_wall_kicks.lua` - Wall kick behavior
- `test_failed_rotation.lua` - Failed rotation state preservation
- `test_automatic_descent.lua` - Automatic piece falling
- `test_lock_delay.lua` - Lock delay mechanism
- `test_spawn_after_lock.lua` - Piece spawning after lock
- `test_game_over.lua` - Game over conditions
- `test_line_clearing.lua` - Line clear detection
- `test_row_collapse.lua` - Row collapse after clear
- `test_score_updates.lua` - Score calculation
- `test_multi_line_bonus.lua` - Multi-line bonus points
- `test_level_progression.lua` - Level advancement
- `test_fall_speed_scaling.lua` - Fall speed by level
- `test_soft_drop.lua` - Soft drop speed increase
- `test_hard_drop.lua` - Hard drop to lowest position
- `test_pause_behavior.lua` - Pause functionality
- `test_pause_round_trip.lua` - Pause/unpause state preservation
- `test_next_piece_availability.lua` - Next piece preview

## Project Structure

```
tests/
├── lib/
│   └── lqc.lua              # Property-based testing library
├── run_tests.lua            # Test runner script
├── test_framework.lua       # Framework verification tests
├── test_*.lua               # Individual test files
└── README.md                # This file
```

## Adding New Tests

1. Create a new test file in the `tests/` directory (e.g., `test_tetromino.lua`)
2. Import the lqc library: `local lqc = require("lqc")`
3. Define your properties and add them with `lqc.addTest(prop)`
4. Add `require("your_test_file")` to `run_tests.lua`

## Tagging Tests

Each property test should be tagged with a comment referencing the design document:

```lua
-- Feature: playdate-tetris, Property 1: Piece spawns at correct location on game start
local prop = lqc.property("piece spawns at correct location", ...)
```

## Code Coverage

The test suite uses LuaCov for code coverage tracking. Coverage is configured via `.luacov` in the project root.

### Coverage Configuration

The `.luacov` file specifies:
- Only track files in the `source/` directory
- Exclude test files and libraries
- Generate reports in `luacov.report.out`

### Current Coverage

As of the latest test run:
- **Overall Coverage: ~91%**
- All core game modules have >77% coverage
- Collision detection: 100%
- Game initialization: 100%
- Playfield: 98%
- Pieces: 98%
- Score management: 97%
- Game state: 90%
- Game manager: 84%
- Input handling: 77%

### Improving Coverage

To identify areas needing more tests:
1. Run the test suite: `lua tests/run_tests.lua`
2. View the detailed report: `cat luacov.report.out`
3. Look for lines marked with `******0` (not executed)
4. Add tests to cover those code paths

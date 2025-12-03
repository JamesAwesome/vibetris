# Playdate Tetris Test Suite

This directory contains property-based tests for the Playdate Tetris implementation.

## Running Tests

To run all tests:

```bash
lua tests/run_tests.lua
```

Or make it executable and run directly:

```bash
chmod +x tests/run_tests.lua
./tests/run_tests.lua
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

## Project Structure

```
tests/
├── lib/
│   └── lqc.lua              # Property-based testing library
├── run_tests.lua            # Test runner script
├── test_framework.lua       # Framework verification tests
└── README.md               # This file
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

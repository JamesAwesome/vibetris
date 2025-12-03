# Playdate Import System Fix

## Issue
The game was using Lua's `require()` function which is not available in the compiled Playdate environment. This caused the error:
```
global 'require' is not callable (a nil value)
```

## Solution
Converted all module loading from `require()` to Playdate's `import` system.

### Changes Made

1. **Module Exports**: Updated all module files to make classes globally available instead of returning them:
   - `source/game/playfield.lua` - Playfield
   - `source/game/collision.lua` - CollisionDetector
   - `source/game/state.lua` - GameState
   - `source/game/score.lua` - ScoreManager
   - `source/game/manager.lua` - GameManager
   - `source/input/init.lua` - InputHandler
   - `source/rendering/init.lua` - Renderer
   - `source/pieces/init.lua` - Tetromino, TetrominoFactory, SHAPES

2. **Main File**: Updated `source/main.lua` to use `import` statements instead of `require()`

3. **Internal References**: Fixed internal `require()` calls in:
   - `source/game/manager.lua` - Now uses global ScoreManager and GameState
   - `source/rendering/init.lua` - Now uses global SHAPES
   - `source/game/init.lua` - Updated to use import system

## How Playdate Import Works

In Playdate:
- Use `import "path/to/module"` instead of `require("path/to/module")`
- Modules should set global variables instead of returning values
- Example:
  ```lua
  -- Old way (doesn't work in compiled Playdate):
  local MyClass = require("mymodule")
  
  -- New way (works in Playdate):
  import "mymodule"
  -- MyClass is now globally available
  ```

## Testing
After these changes, the game compiles successfully with `pdc source Tetris.pdx` and should run in the Playdate Simulator without errors.

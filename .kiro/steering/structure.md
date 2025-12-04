# Project Structure & Conventions

## Directory Layout

```
source/                  # Game source code
├── main.lua            # Entry point and game loop
├── game/               # Game state management and logic
│   ├── manager.lua     # State machine (menu, playing, paused, gameover)
│   ├── state.lua       # Piece falling, locking, spawning
│   ├── playfield.lua   # 10x20 grid management
│   ├── collision.lua   # Collision detection
│   └── score.lua       # Scoring and level progression
├── pieces/             # Tetromino definitions and factory
│   └── init.lua
├── input/              # Input handling (crank, D-pad, buttons)
│   └── init.lua
├── rendering/          # Drawing and visual effects
│   └── init.lua
└── ui/                 # UI components (start screen, menus)
    └── start_screen.lua

tests/                   # Test suite
├── lib/lqc.lua         # Property-based testing library (vendored)
├── run_tests.lua       # Test runner
└── test_*.lua          # Individual test files

Vibetris.pdx/           # Compiled game bundle (generated)
```

## Code Organization Patterns

### Module Structure
- Each module uses Lua table-based OOP pattern
- Modules export via both `_G` global assignment and `return` for compatibility
- Constructor pattern: `ModuleName:new(...)`
- Use `local` for private functions and variables

### Module Export Pattern (CRITICAL)
All modules MUST be compatible with both Playdate's `import` and Lua's `require`:

```lua
-- At the end of every module file:
if _G then
    _G.ModuleName = ModuleName
end
return ModuleName
```

This dual export ensures:
- Playdate's `import` statement can access modules via `_G` global
- Lua's `require` statement can access modules via `return` value
- Tests can run in standard Lua environment outside Playdate simulator

### Naming Conventions
- **Classes/Modules**: PascalCase (e.g., `GameManager`, `TetrominoFactory`)
- **Functions**: camelCase (e.g., `updatePlaying`, `isGameOver`)
- **Variables**: camelCase (e.g., `currentPiece`, `fallInterval`)
- **Constants**: Use `<const>` annotation (e.g., `local gfx <const> = playdate.graphics`)

### Import Pattern
```lua
import "CoreLibs/graphics"  -- Playdate SDK imports
import "game/manager"       -- Local module imports
```

### State Management
- Game uses explicit state machine pattern
- Valid states: `"start_screen"`, `"menu"`, `"playing"`, `"paused"`, `"gameover"`
- State transitions handled through `changeState()` method

## Architecture Principles

1. **Separation of Concerns**: Game logic, rendering, and input are separate modules
2. **Dependency Injection**: Components passed to constructors (e.g., GameManager receives all dependencies)
3. **Single Responsibility**: Each module has a clear, focused purpose
4. **Testability**: Core logic separated from Playdate APIs for easier testing

## Testing Conventions

- Test files named `test_*.lua`
- Use property-based testing with lqc for comprehensive coverage
- Each test file focuses on specific functionality
- Tests should be runnable outside Playdate simulator

## File Naming
- Lua source files: lowercase with underscores (e.g., `start_screen.lua`)
- Module entry points: `init.lua`
- Test files: `test_` prefix (e.g., `test_collision_detection.lua`)

## Comments
- Module-level comments describe purpose and responsibilities
- Function comments for complex logic
- Inline comments for non-obvious code
- Keep comments concise and meaningful

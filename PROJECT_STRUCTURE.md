# Playdate Tetris - Project Structure

## Directory Layout

```
playdate-tetris/
├── source/                  # Game source code
│   ├── main.lua            # Entry point and game loop
│   ├── game/               # Game state management
│   │   └── init.lua
│   ├── pieces/             # Tetromino definitions and factory
│   │   └── init.lua
│   ├── input/              # Input handling (crank, D-pad, buttons)
│   │   └── init.lua
│   └── rendering/          # Drawing and visual effects
│       └── init.lua
├── tests/                   # Property-based test suite
│   ├── lib/
│   │   └── lqc.lua         # lua-quickcheck testing library
│   ├── run_tests.lua       # Test runner
│   ├── test_framework.lua  # Framework verification tests
│   └── README.md           # Testing documentation
├── Tetris.pdx/             # Compiled game bundle
├── .kiro/                  # Kiro specs and documentation
│   └── specs/
│       └── playdate-tetris/
│           ├── requirements.md
│           ├── design.md
│           └── tasks.md
└── pdxinfo                 # Playdate game metadata
```

## Module Organization

### source/game/
Game state management, coordination between components, and the main game loop logic.

**Contains:**
- GameManager - Overall game flow and state machine (menu, playing, paused, gameover)
- GameState - Manages falling pieces, lock delay, and piece spawning
- Playfield - 10x20 grid management and line clearing
- CollisionDetector - Collision detection logic
- ScoreManager - Scoring and level progression

### source/pieces/
Tetromino shapes, rotation states, and piece generation.

**Contains:**
- Tetromino - Piece representation and transformations
- TetrominoFactory - Random piece generation and preview management
- Shape definitions for all 7 piece types (I, O, T, S, Z, J, L)

### source/input/
Input handling for all Playdate controls.

**Contains:**
- InputHandler - Crank rotation, D-pad, and button processing
- Auto-repeat logic for held buttons
- Haptic feedback triggers

### source/rendering/
All drawing operations and visual effects.

**Will contain:**
- Renderer - Main rendering coordinator
- Playfield rendering
- Tetromino rendering with distinct patterns
- UI rendering (score, level, lines, next piece)
- Animation system for line clears

## Testing

Run tests with:
```bash
lua tests/run_tests.lua
```

See `tests/README.md` for detailed testing documentation.

## Development Workflow

1. Implement functionality in appropriate module directory
2. Write property-based tests in `tests/`
3. Run tests to verify correctness
4. Build and test in Playdate Simulator
5. Iterate based on feedback

## Building

The Playdate SDK will compile the `source/` directory into `Tetris.pdx/` for deployment to the Playdate device or simulator.

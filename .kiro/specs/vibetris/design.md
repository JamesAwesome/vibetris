# Design Document

## Overview

This Tetris implementation for Playdate follows a component-based architecture that separates game logic, input handling, and rendering. The design leverages Lua's table-based object system and the Playdate SDK's sprite and graphics APIs. The game supports dual rotation input methods: the unique crank-based rotation mechanic is integrated through the SDK's crank input system (providing tactile feedback through the device's haptic capabilities), and traditional button-based rotation via the B button for players who prefer conventional controls.

The game loop follows the standard Playdate pattern with a `playdate.update()` function called every frame. Game state is managed through a finite state machine that handles menu, playing, paused, and game over states.

## Architecture

The system is organized into the following layers:

1. **Game State Layer**: Manages overall game state (menu, playing, paused, game over) and coordinates between components
2. **Game Logic Layer**: Handles Tetris-specific rules including piece movement, rotation, collision detection, line clearing, and scoring
3. **Input Layer**: Processes crank rotation, D-pad input, and button presses
4. **Rendering Layer**: Draws the playfield, pieces, UI elements, and animations using Playdate graphics APIs

Data flows from input → game logic → rendering each frame. The game logic layer maintains the authoritative game state, while the rendering layer is purely presentational.

## Components and Interfaces

### GameManager

Coordinates overall game flow and state transitions.

**Responsibilities:**
- Initialize game components
- Manage game state (menu, playing, paused, game over)
- Coordinate update and render calls
- Handle state transitions

**Interface:**
```lua
GameManager = {}
function GameManager:init()
function GameManager:update()
function GameManager:changeState(newState)
```

### Playfield

Represents the 10x20 grid where pieces fall and lock.

**Responsibilities:**
- Store locked block positions
- Check for completed lines
- Clear completed lines and collapse rows above
- Detect collision with locked blocks

**Interface:**
```lua
Playfield = {}
function Playfield:init(width, height)
function Playfield:isOccupied(x, y)
function Playfield:lockPiece(piece)
function Playfield:checkLines()
function Playfield:clearLines(lines)
```

### Tetromino

Represents a falling piece with its shape, position, and orientation.

**Responsibilities:**
- Store piece type, position, and rotation state
- Provide block positions for current orientation
- Handle rotation transformations
- Validate movements against playfield boundaries

**Interface:**
```lua
Tetromino = {}
function Tetromino:new(type, x, y)
function Tetromino:getBlocks()
function Tetromino:rotate(direction)
function Tetromino:move(dx, dy)
function Tetromino:tryWallKick(rotation)
```

### TetrominoFactory

Creates Tetromino instances with proper shapes and randomization.

**Responsibilities:**
- Define the seven standard Tetromino shapes (I, O, T, S, Z, J, L)
- Generate random pieces
- Manage next piece preview

**Interface:**
```lua
TetrominoFactory = {}
function TetrominoFactory:init()
function TetrominoFactory:getRandomPiece()
function TetrominoFactory:peekNext()
```

### InputHandler

Processes player input from crank, D-pad, and buttons.

**Responsibilities:**
- Read crank angle changes and trigger rotations
- Handle B button presses for rotation
- Handle D-pad movement with auto-repeat
- Process button presses for hard drop and pause
- Provide haptic feedback for crank rotations

**Interface:**
```lua
InputHandler = {}
function InputHandler:init()
function InputHandler:update()
function InputHandler:getCrankRotation()
function InputHandler:isRotateButtonPressed()
function InputHandler:getMovement()
function InputHandler:isHardDropPressed()
function InputHandler:isPausePressed()
```

### CollisionDetector

Checks for collisions between Tetrominos and the playfield.

**Responsibilities:**
- Validate piece positions against playfield boundaries
- Check for overlaps with locked blocks
- Support wall kick collision testing

**Interface:**
```lua
CollisionDetector = {}
function CollisionDetector:canMoveTo(piece, playfield, x, y)
function CollisionDetector:canRotate(piece, playfield, rotation)
function CollisionDetector:isValidPosition(blocks, playfield)
```

### ScoreManager

Tracks score, level, and lines cleared.

**Responsibilities:**
- Calculate points for line clears
- Track total lines cleared
- Determine current level
- Calculate fall speed based on level

**Interface:**
```lua
ScoreManager = {}
function ScoreManager:init()
function ScoreManager:addLines(count)
function ScoreManager:getScore()
function ScoreManager:getLevel()
function ScoreManager:getFallSpeed()
```

### Renderer

Draws all game elements to the screen.

**Responsibilities:**
- Render playfield grid and locked blocks
- Draw active and preview Tetrominos
- Display score, level, and lines cleared
- Show pause and game over screens
- Animate line clears

**Interface:**
```lua
Renderer = {}
function Renderer:init()
function Renderer:drawPlayfield(playfield)
function Renderer:drawPiece(piece)
function Renderer:drawUI(scoreManager)
function Renderer:drawPreview(piece)
```

## Data Models

### Playfield Data Structure

```lua
{
  width = 10,
  height = 20,
  grid = {}, -- 2D array: grid[y][x] = blockType or nil
}
```

### Tetromino Data Structure

```lua
{
  type = "I", -- One of: I, O, T, S, Z, J, L
  x = 4,      -- Column position (0-based)
  y = 0,      -- Row position (0-based)
  rotation = 0, -- 0, 1, 2, or 3 (0° 90° 180° 270°)
  shapes = {}, -- 4 rotation states, each containing block offsets
}
```

### Tetromino Shapes

Each piece type has 4 rotation states defined as arrays of {x, y} offsets from the piece's origin:

```lua
SHAPES = {
  I = {
    [0] = {{0,1}, {1,1}, {2,1}, {3,1}},
    [1] = {{2,0}, {2,1}, {2,2}, {2,3}},
    [2] = {{0,2}, {1,2}, {2,2}, {3,2}},
    [3] = {{1,0}, {1,1}, {1,2}, {1,3}},
  },
  -- Similar definitions for O, T, S, Z, J, L
}
```

### Game State

```lua
{
  state = "playing", -- "menu", "playing", "paused", "gameover"
  playfield = Playfield,
  currentPiece = Tetromino,
  nextPiece = Tetromino,
  scoreManager = ScoreManager,
  fallTimer = 0,
  lockTimer = 0,
  lastCrankAngle = 0,
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

After reviewing all testable properties from the prework, several can be consolidated:

- Properties 2.1 and 2.2 (clockwise/counter-clockwise rotation) can be combined into a single rotation property
- Properties 3.1 and 3.2 (left/right movement) can be combined into a single horizontal movement property
- Properties 4.1 and 4.2 (soft drop speed changes) can be combined into a single soft drop property
- Property 1.2 (automatic falling) is implicitly tested by other movement properties
- Property 7.2 (next piece update) is a consequence of 1.4 (spawn after lock) and can be consolidated

This reduces redundancy while maintaining comprehensive coverage of all testable behaviors.

### Correctness Properties

Property 1: Piece spawns at correct location on game start
*For any* new game initialization, the first Tetromino should appear at the top center of the playfield (x=3 or x=4, y=0)
**Validates: Requirements 1.1**

Property 2: Automatic piece descent
*For any* active Tetromino and elapsed fall interval, the piece's y position should increase by exactly 1 row
**Validates: Requirements 1.2**

Property 3: Lock delay preserves piece state
*For any* Tetromino that cannot move downward, the piece should remain in its current position until lock delay expires, then its blocks should be added to the playfield grid
**Validates: Requirements 1.3**

Property 4: Spawn after lock
*For any* locked Tetromino, a new Tetromino should appear at the spawn location immediately after locking
**Validates: Requirements 1.4**

Property 5: Game over on blocked spawn
*For any* playfield state where the spawn location contains blocks, attempting to spawn a new piece should transition the game state to "gameover"
**Validates: Requirements 1.5**

Property 6: Crank rotation changes piece orientation
*For any* Tetromino and crank rotation direction (clockwise or counter-clockwise), the piece's rotation state should change by ±90 degrees when rotation is valid
**Validates: Requirements 2.1, 2.2**

Property 22: B button rotation changes piece orientation
*For any* Tetromino, pressing the B button should rotate the piece 90 degrees clockwise when rotation is valid
**Validates: Requirements 2.3**

Property 7: Wall kick attempts on blocked rotation
*For any* Tetromino where direct rotation would cause collision, the system should attempt wall kick position adjustments before rejecting the rotation
**Validates: Requirements 2.3**

Property 8: Failed rotation preserves state
*For any* Tetromino where rotation and all wall kicks fail, the piece's position and rotation state should remain unchanged
**Validates: Requirements 2.4**

Property 9: Horizontal movement changes position
*For any* Tetromino and valid horizontal direction (left or right), the piece's x position should change by ±1 column
**Validates: Requirements 3.1, 3.2**

Property 10: Invalid movements are rejected
*For any* Tetromino and movement that would cause collision with playfield boundaries or locked blocks, the piece's position should remain unchanged
**Validates: Requirements 3.3**

Property 11: Soft drop increases fall speed
*For any* game state, holding the down button should decrease the fall interval, and releasing it should restore the original interval based on current level
**Validates: Requirements 4.1, 4.2**

Property 12: Hard drop moves to lowest position
*For any* Tetromino and playfield state, hard drop should move the piece to the lowest y position where no collision occurs, then immediately lock it
**Validates: Requirements 4.3**

Property 13: Complete rows are cleared
*For any* playfield state where a horizontal row is completely filled with blocks, that row should be removed from the grid
**Validates: Requirements 5.1**

Property 14: Rows collapse after line clear
*For any* line clear operation, all rows above the cleared row(s) should move downward by the number of rows cleared
**Validates: Requirements 5.2**

Property 15: Multi-line clears award bonus points
*For any* number of simultaneously cleared lines N, the score awarded should be greater than N times the single-line score (score(N) > N * score(1) for N > 1)
**Validates: Requirements 5.3**

Property 16: Line clears update score
*For any* line clear operation clearing N lines, the score should increase by a deterministic amount based on N and the current level
**Validates: Requirements 5.4**

Property 17: Level increases with line threshold
*For any* game state, when total lines cleared reaches a multiple of 10, the level should increment by 1
**Validates: Requirements 6.1**

Property 18: Higher levels have faster fall speed
*For any* two levels L1 and L2 where L2 > L1, the fall interval at L2 should be less than the fall interval at L1
**Validates: Requirements 6.2**

Property 19: Next piece is always available
*For any* game state where state is "playing", there should always be a valid next Tetromino defined
**Validates: Requirements 7.1**

Property 20: Pause prevents game updates
*For any* game state where state is "paused", Tetromino positions and game timers should not change over update cycles
**Validates: Requirements 9.2**

Property 21: Pause-unpause round trip
*For any* game state, transitioning to "paused" then back to "playing" should preserve all game state (piece positions, score, level, playfield)
**Validates: Requirements 9.3**

## Error Handling

### Input Errors

- **Invalid crank angles**: The system should handle crank angle wraparound (0° to 360°) gracefully
- **Rapid input**: Multiple inputs in a single frame should be processed in order without dropping inputs
- **Simultaneous inputs**: Conflicting inputs (e.g., left and right pressed together) should be resolved with a priority system

### Game State Errors

- **Invalid piece positions**: All piece movements should be validated before applying; invalid states should never be committed
- **Playfield overflow**: Pieces should never be placed outside the playfield boundaries
- **Missing next piece**: The system should always maintain a valid next piece; if generation fails, use a fallback piece type

### Rendering Errors

- **Off-screen rendering**: All draw calls should be clipped to screen boundaries
- **Missing sprites**: If sprite assets fail to load, fall back to simple geometric shapes
- **Performance degradation**: If frame rate drops below 20 FPS, reduce visual effects

### Recovery Strategies

- **Corrupted game state**: If an invalid state is detected, reset to a safe state (new game or last valid checkpoint)
- **SDK errors**: Wrap all Playdate SDK calls in error handlers that log issues and attempt graceful degradation
- **Memory issues**: Implement object pooling for frequently created objects (Tetrominos, timers) to reduce garbage collection pressure

## Testing Strategy

This project will use a dual testing approach combining unit tests and property-based tests to ensure comprehensive correctness.

### Unit Testing

Unit tests will verify specific examples and integration points:

- **Tetromino shape definitions**: Verify each of the 7 piece types has correct block positions for all 4 rotations
- **Collision detection edge cases**: Test boundary conditions (edges of playfield, corners)
- **Scoring calculations**: Verify point values for 1, 2, 3, and 4 line clears at various levels
- **State transitions**: Test specific state changes (menu → playing, playing → paused → playing, playing → gameover)
- **Wall kick tables**: Verify wall kick offsets for each piece type and rotation

Unit tests will be written using a simple Lua testing framework and placed in a `tests/` directory alongside the source code.

### Property-Based Testing

Property-based tests will verify universal properties across all inputs using **lua-quickcheck**, a property-based testing library for Lua.

**Configuration:**
- Each property test will run a minimum of 100 iterations with randomly generated inputs
- Tests will use custom generators for Tetrominos, playfield states, and game states
- Each property test will be tagged with a comment referencing the design document property

**Tagging Format:**
```lua
-- Feature: vibetris, Property 10: Invalid movements are rejected
```

**Property Test Coverage:**
- Each of the 21 correctness properties listed above will be implemented as a single property-based test
- Generators will create random Tetrominos (all types, positions, rotations)
- Generators will create random playfield states (empty, partially filled, nearly full)
- Generators will create random game states (different levels, scores, piece combinations)

**Example Property Test Structure:**
```lua
-- Feature: vibetris, Property 12: Hard drop moves to lowest position
property("hard drop moves piece to lowest valid position", function()
  local piece = generateRandomTetromino()
  local playfield = generateRandomPlayfield()
  local initialY = piece.y
  
  local lowestY = calculateLowestValidPosition(piece, playfield)
  hardDrop(piece, playfield)
  
  return piece.y == lowestY and isLocked(piece, playfield)
end)
```

### Integration Testing

While unit and property tests cover logic, manual integration testing on the Playdate Simulator will verify:
- Crank input responsiveness and haptic feedback
- Visual rendering on the monochrome display
- Frame rate performance
- Overall game feel and timing

### Test Execution

Tests will be run using:
```bash
lua tests/run_tests.lua
```

All tests must pass before any code is merged or released.

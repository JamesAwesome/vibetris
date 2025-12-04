# Vibetris for Playdate

A classic block-stacking game built for the Playdate console using the Playdate Lua SDK.

![Vibetris Demo](https://github.com/JamesAwesome/vibetris/raw/main/vibetris-demo.gif)

## Features

- Classic gameplay with all 7 standard tetrominos
- Dual rotation input: use the Playdate crank or B button
- Traditional controls: D-pad for movement, A/Up for hard drop
- Progressive difficulty with increasing fall speed
- Line clearing with visual feedback animation
- Score tracking and level progression
- Pause functionality
- Comprehensive test suite with 90%+ code coverage

## Setup

### Prerequisites

1. Install the [Playdate SDK](https://play.date/dev/)
2. Set the `PLAYDATE_SDK_PATH` environment variable to your SDK location

### Development Dependencies (Optional)

For running tests and code coverage:

**On macOS:**
```bash
brew install lua luarocks
```

**On Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install lua5.4 luarocks

# Fedora
sudo dnf install lua luarocks
```

**Install test dependencies:**
```bash
luarocks install --only-deps vibetris-dev-1.rockspec
```

This will install:
- LuaCov (code coverage tool)

## Building

```bash
pdc source Vibetris.pdx
```

## Running

Open the generated `Vibetris.pdx` file with the Playdate Simulator, or run:

```bash
open Vibetris.pdx
```

## Testing

Run the comprehensive test suite:

```bash
lua tests/run_tests.lua
```

Or via LuaRocks:

```bash
luarocks test vibetris-dev-1.rockspec
```

The test suite includes:
- 13 unit tests
- 24 property-based tests (100 iterations each)
- Automatic code coverage reporting

View detailed coverage:
```bash
cat luacov.report.out
```

See [tests/README.md](tests/README.md) for more information.

## Development

### Project Structure

```
source/
├── main.lua              # Entry point
├── game/                 # Game logic
│   ├── collision.lua     # Collision detection
│   ├── manager.lua       # Game state management
│   ├── playfield.lua     # 10x20 grid
│   ├── score.lua         # Scoring and levels
│   └── state.lua         # Game state
├── pieces/               # Tetromino definitions
├── input/                # Input handling (crank, buttons)
└── rendering/            # Graphics rendering

tests/
├── test_*.lua            # Test files
├── lib/lqc.lua          # Property-based testing library
└── run_tests.lua        # Test runner
```

### Key Files

- `source/main.lua` - Entry point and game loop
- `source/game/manager.lua` - Coordinates game flow and state transitions
- `source/pieces/init.lua` - Tetromino shapes and factory
- `source/rendering/init.lua` - All rendering logic

### Resources

- [Playdate SDK Documentation](https://sdk.play.date/)
- [Design Document](.kiro/specs/vibetris/design.md)
- [Requirements](.kiro/specs/vibetris/requirements.md)

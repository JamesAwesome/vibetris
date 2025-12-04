# Technology Stack

## Platform & SDK

- **Platform**: Playdate handheld console
- **SDK**: Playdate Lua SDK
- **Language**: Lua (compatible with Lua 5.1+)
- **Graphics**: 1-bit monochrome (400x240 pixels)

## Build System

- **Compiler**: `pdc` (Playdate Compiler) from Playdate SDK
- **Package Manager**: LuaRocks (for development dependencies)
- **Environment Variable**: `PLAYDATE_SDK_PATH` must be set

## Dependencies

### Runtime
- Playdate SDK CoreLibs (graphics, sprites, timer)

### Development/Testing
- LuaCov (code coverage tool)
- lua-quickcheck (property-based testing library, vendored in `tests/lib/lqc.lua`)

## Common Commands

### Building
```bash
pdc source Vibetris.pdx
```

### Running
```bash
open Vibetris.pdx  # Opens in Playdate Simulator
```

### Testing
```bash
lua tests/run_tests.lua
```

Or via LuaRocks:
```bash
luarocks test vibetris-dev-1.rockspec
```

### Code Coverage
```bash
# After running tests, view coverage report
cat luacov.report.out
```

### Installing Test Dependencies
```bash
luarocks install --only-deps vibetris-dev-1.rockspec
```

## Testing Approach

- Property-based testing using lua-quickcheck (lqc)
- 90%+ code coverage target
- Tests run in standard Lua environment (not Playdate simulator)
- Mock Playdate APIs in test environment when needed

## Import vs Require Compatibility

**CRITICAL**: Playdate uses `import` while Lua uses `require`. All modules must support both:

```lua
-- Module export pattern (at end of every module):
if _G then
    _G.ModuleName = ModuleName
end
return ModuleName
```

This allows:
- Playdate runtime to use `import "module/path"`
- Test suite to use `require("module.path")`

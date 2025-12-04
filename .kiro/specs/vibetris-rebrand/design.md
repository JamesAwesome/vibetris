# Design Document: Vibetris Rebrand

## Overview

This design outlines the rebranding of the Playdate Tetris game to "Vibetris" and the creation of a custom bubble letter logo for the start screen. The rebrand involves systematic updates across the entire codebase, file structure, documentation, and build configuration while preserving all existing game functionality. A new visual identity will be established through a custom logo that displays prominently when the game launches.

The rebrand is purely cosmetic and does not affect game mechanics, state management, or core functionality. All existing tests will continue to pass after the rebrand, with only test descriptions updated where they reference the game name.

## Architecture

The rebrand touches multiple layers of the application:

1. **File System Layer**: Directory names, file names, and package identifiers
2. **Configuration Layer**: Build configuration files (pdxinfo, rockspec)
3. **Code Layer**: String literals, comments, and module references where appropriate
4. **Documentation Layer**: README, project structure docs, and spec files
5. **Asset Layer**: New logo image asset for the start screen
6. **UI Layer**: Start screen rendering to display the logo

The architecture remains unchanged; only naming and branding elements are modified.

## Components and Interfaces

### 1. File System Renaming

**Affected Components:**
- `Tetris.pdx/` → `Vibetris.pdx/`
- `playdate-tetris-dev-1.rockspec` → `vibetris-dev-1.rockspec`
- `.kiro/specs/playdate-tetris/` → `.kiro/specs/vibetris/`

**Interface:** File system operations (rename, move)

### 2. Configuration Updates

**pdxinfo File:**
```
name=Vibetris
author=Your Name
description=Classic block-stacking game for Playdate
bundleID=com.yourname.vibetris
version=1.0
buildNumber=1
imagePath=images/
```

**Rockspec File:**
- Package name: `vibetris`
- URLs and descriptions updated to reference Vibetris
- Module paths remain unchanged (internal structure)

### 3. Logo Asset

**Component:** `source/images/vibetris-logo.png`

**Specifications:**
- Format: PNG with 1-bit depth (black and white)
- Dimensions: Approximately 300x80 pixels (fits Playdate 400x240 screen)
- Style: Bubble letters - rounded, three-dimensional appearance
- Content: The word "VIBETRIS" in stylized bubble lettering
- Compatibility: Playdate SDK image format requirements

**Creation Method:**
Since we cannot generate images programmatically, the logo will be created as a simple text-based placeholder that can be replaced with a proper graphic design later. The placeholder will use ASCII art or a simple text rendering that suggests the bubble letter style.

### 4. Start Screen Rendering

**Component:** Modified `source/main.lua` or new `source/ui/start_screen.lua`

**Interface:**
```lua
StartScreen = {}
StartScreen.__index = StartScreen

function StartScreen:new()
  local self = setmetatable({}, StartScreen)
  self.logo = gfx.image.new("images/vibetris-logo")
  self.displayed = false
  self.displayDuration = 2.0 -- seconds
  self.timer = 0
  return self
end

function StartScreen:update(dt)
  if self.displayed then
    self.timer = self.timer + dt
    if self.timer >= self.displayDuration then
      return true -- Signal to transition to game
    end
  end
  return false
end

function StartScreen:render()
  gfx.clear()
  if self.logo then
    -- Center the logo on screen
    local screenWidth = 400
    local screenHeight = 240
    local logoWidth = self.logo:getSize()
    local x = (screenWidth - logoWidth) / 2
    local y = (screenHeight - self.logo:getHeight()) / 2
    self.logo:draw(x, y)
  else
    -- Fallback text rendering
    gfx.drawTextAligned("VIBETRIS", 200, 120, kTextAlignment.center)
  end
end

function StartScreen:show()
  self.displayed = true
  self.timer = 0
end
```

**Integration:** The game manager will be modified to include a start screen state that displays before entering the main menu or gameplay.

### 5. Documentation Updates

**Affected Files:**
- `README.md` - Update title, descriptions, build commands
- `PROJECT_STRUCTURE.md` - Update directory references
- `.kiro/specs/playdate-tetris/` - Rename directory and update internal references

**Pattern:** Replace "Tetris" with "Vibetris" and "tetris" with "vibetris" in appropriate contexts

## Data Models

No new data models are required. Existing models remain unchanged.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Consistent branding in file system
*For any* file or directory in the project, if it previously contained "tetris" in its name, it should now contain "vibetris" instead (excluding intentional historical references or external dependencies).
**Validates: Requirements 1.2**

### Property 2: Configuration consistency
*For any* configuration file (pdxinfo, rockspec), all references to the game name should use "Vibetris" or "vibetris" consistently.
**Validates: Requirements 1.3, 1.5**

### Property 3: Logo presence on start screen
*For any* game launch sequence, the start screen should display the logo (either the image asset or fallback text) before transitioning to gameplay.
**Validates: Requirements 2.1, 2.2**

### Property 4: Logo visibility
*For any* logo rendering, the logo should be positioned within the visible screen bounds (0-400 width, 0-240 height) and centered appropriately.
**Validates: Requirements 2.2, 2.3**

### Property 5: Build output naming
*For any* successful build operation, the output package should be named "Vibetris.pdx" rather than "Tetris.pdx".
**Validates: Requirements 1.4**

### Property 6: Documentation consistency
*For any* documentation file, references to the game should use "Vibetris" except where historical context requires "Tetris".
**Validates: Requirements 1.3**

### Property 7: Test suite integrity
*For any* test execution after the rebrand, all tests that passed before the rebrand should continue to pass (with only name references updated).
**Validates: Requirements 3.4**

## Error Handling

### File System Errors
- If file/directory renaming fails, provide clear error messages indicating which operations succeeded and which failed
- Implement rollback capability if partial rename operations occur
- Verify all file references are updated before deleting old files

### Asset Loading Errors
- If logo image fails to load, fall back to text-based rendering
- Log warning when logo asset is missing but continue execution
- Provide clear console output indicating fallback mode

### Build Errors
- If PDX build fails after rebrand, verify all import statements and file paths
- Check that pdxinfo is properly formatted
- Ensure rockspec syntax is valid

## Testing Strategy

### Unit Tests

Since this is primarily a refactoring/renaming task, unit tests will focus on:

1. **File System Verification**: Verify that renamed files exist and old files are removed
2. **Configuration Parsing**: Verify pdxinfo and rockspec contain correct values
3. **Logo Loading**: Test that logo asset loads correctly or falls back appropriately
4. **Start Screen State**: Test that start screen displays and transitions correctly

### Property-Based Tests

Property-based tests will verify the correctness properties defined above:

1. **Property 1 Test**: Scan file system for any remaining "tetris" references in file/directory names
2. **Property 2 Test**: Parse configuration files and verify all game name fields
3. **Property 3 Test**: Simulate game launch and verify start screen appears
4. **Property 4 Test**: Generate random screen positions and verify logo stays within bounds
5. **Property 5 Test**: Execute build and verify output directory name
6. **Property 6 Test**: Scan documentation for consistent branding
7. **Property 7 Test**: Run existing test suite and verify pass rate

**Testing Library:** Since this is a Lua project, we'll use the existing `lqc.lua` (Lua QuickCheck) library for property-based testing.

**Test Configuration:**
- Minimum 100 iterations per property test
- Each property test tagged with: `-- Feature: vibetris-rebrand, Property X: [description]`

### Integration Tests

1. **End-to-End Build Test**: Execute full build pipeline and verify Vibetris.pdx runs in simulator
2. **Start Screen Integration**: Launch game and verify logo displays before gameplay begins
3. **Regression Test**: Run all existing game tests to ensure functionality is preserved

### Manual Verification

Some aspects require manual verification:
- Visual appearance of bubble letter logo (aesthetic quality)
- Logo readability on actual Playdate hardware
- Playdate menu displays "Vibetris" correctly

## Implementation Notes

### Logo Creation Approach

Since we cannot generate pixel art programmatically within this system, we'll create a placeholder approach:

1. **Phase 1 (Automated)**: Create a simple text-based logo using Playdate's text rendering
2. **Phase 2 (Manual)**: Developer creates proper bubble letter logo using external tools (Aseprite, Photoshop, etc.)
3. **Phase 3 (Integration)**: Replace placeholder with final logo asset

For the automated phase, we can create a stylized text rendering that suggests bubble letters through:
- Large font size
- Bold/thick characters
- Spacing and positioning
- Optional: Simple geometric shapes drawn around letters to suggest "bubble" effect

### Backward Compatibility

The rebrand breaks backward compatibility in terms of:
- Save file locations (if any)
- Package identifier
- File paths

If save data preservation is required, migration logic should be added to check for old "tetris" save locations and copy to new "vibetris" locations.

### Rollback Plan

Maintain a git branch with the pre-rebrand state to enable quick rollback if issues arise. Document the specific commit hash before beginning the rebrand.

# Implementation Plan: Vibetris Rebrand

- [x] 1. Update configuration files
  - Update `pdxinfo` to use "Vibetris" branding (name, description, bundleID)
  - Update `playdate-tetris-dev-1.rockspec` to `vibetris-dev-1.rockspec` with new package name and descriptions
  - _Requirements: 1.2, 1.3, 1.5, 3.5_

- [x] 1.1 Write property test for configuration consistency
  - **Property 2: Configuration consistency**
  - **Validates: Requirements 1.3, 1.5**

- [x] 2. Update documentation files
  - Update `README.md` to replace "Tetris" with "Vibetris" in title, descriptions, and build commands
  - Update `PROJECT_STRUCTURE.md` to reflect new directory and file names
  - Update `.gitignore` if it contains "Tetris" references
  - _Requirements: 1.3_

- [x] 2.1 Write property test for documentation consistency
  - **Property 6: Documentation consistency**
  - **Validates: Requirements 1.3**

- [x] 3. Create logo asset and start screen component
  - Create `source/images/` directory if it doesn't exist
  - Create placeholder logo asset `source/images/vibetris-logo.png` or text-based fallback
  - Create `source/ui/start_screen.lua` module with StartScreen class
  - Implement logo loading with fallback to text rendering
  - Implement start screen rendering with centered logo display
  - _Requirements: 2.1, 2.2, 2.3, 2.5_

- [x] 3.1 Write property test for logo visibility
  - **Property 4: Logo visibility**
  - **Validates: Requirements 2.2, 2.3**

- [x] 3.2 Write unit test for logo loading and fallback
  - Test logo asset loads correctly
  - Test fallback to text rendering when asset missing
  - _Requirements: 2.1, 2.5_

- [x] 4. Integrate start screen into game flow
  - Modify `source/main.lua` to import start screen module
  - Add start screen state to game initialization
  - Implement start screen display on game launch
  - Implement transition from start screen to main game after delay or button press
  - _Requirements: 2.1, 2.4_

- [x] 4.1 Write property test for start screen presence
  - **Property 3: Logo presence on start screen**
  - **Validates: Requirements 2.1, 2.2**

- [x] 4.2 Write unit test for start screen state transitions
  - Test start screen displays on launch
  - Test transition to game after timeout
  - Test transition on button press
  - _Requirements: 2.4_

- [x] 5. Update code references where appropriate
  - Search codebase for "Tetris" or "tetris" in comments and string literals
  - Update references to "Vibetris" or "vibetris" where it refers to the game name
  - Leave technical terms like "Tetromino" unchanged
  - Update test descriptions that reference the game name
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ]* 5.1 Write property test for code reference consistency
  - **Property 1: Consistent branding in file system**
  - **Validates: Requirements 1.2**

- [x] 6. Rename directories and files
  - Rename `Tetris.pdx/` to `Vibetris.pdx/` (if it exists)
  - Rename `.kiro/specs/playdate-tetris/` to `.kiro/specs/vibetris/`
  - Update any internal references in spec files to new directory name
  - _Requirements: 1.2, 1.4_

- [ ]* 6.1 Write property test for build output naming
  - **Property 5: Build output naming**
  - **Validates: Requirements 1.4**

- [x] 7. Checkpoint - Verify build and test suite
  - Build the game using `pdc source Vibetris.pdx`
  - Run the complete test suite to ensure all tests pass
  - Verify the game launches in Playdate Simulator with start screen
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 7.1 Write property test for test suite integrity
  - **Property 7: Test suite integrity**
  - **Validates: Requirements 3.4**

- [x] 8. Final verification and cleanup
  - Verify no remaining "Tetris" references in file names or directories
  - Verify Playdate menu displays "Vibetris"
  - Verify start screen logo displays correctly
  - Remove any backup files or temporary artifacts
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2_

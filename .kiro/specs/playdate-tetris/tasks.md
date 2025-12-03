# Implementation Plan

- [x] 1. Set up project structure and testing framework
  - Create directory structure for game modules (game/, pieces/, input/, rendering/)
  - Set up lua-quickcheck for property-based testing
  - Create test runner script
  - _Requirements: All_

- [x] 2. Implement Tetromino shapes and factory
  - Define the 7 standard Tetromino types (I, O, T, S, Z, J, L) with all 4 rotation states
  - Implement TetrominoFactory with random piece generation
  - Implement next piece preview management
  - _Requirements: 1.1, 1.4, 7.1, 7.2_

- [x] 2.1 Write unit tests for Tetromino shapes
  - Verify each piece type has correct block positions for all rotations
  - Test that all shapes have exactly 4 blocks
  - _Requirements: 1.1_

- [x] 2.2 Write property test for piece spawning
  - **Property 1: Piece spawns at correct location on game start**
  - **Validates: Requirements 1.1**

- [x] 3. Implement Playfield and collision detection
  - Create Playfield class with 10x20 grid
  - Implement grid occupancy checking
  - Implement CollisionDetector for boundary and block overlap checking
  - _Requirements: 1.3, 3.3, 10.1_

- [x] 3.1 Write property test for collision detection
  - **Property 10: Invalid movements are rejected**
  - **Validates: Requirements 3.3**

- [ ] 4. Implement Tetromino movement and rotation
  - Implement horizontal movement (left/right)
  - Implement rotation with wall kick system
  - Implement movement validation against playfield
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3_

- [ ] 4.1 Write property test for horizontal movement
  - **Property 9: Horizontal movement changes position**
  - **Validates: Requirements 3.1, 3.2**

- [ ] 4.2 Write property test for rotation
  - **Property 6: Crank rotation changes piece orientation**
  - **Validates: Requirements 2.1, 2.2**

- [ ] 4.3 Write property test for wall kicks
  - **Property 7: Wall kick attempts on blocked rotation**
  - **Validates: Requirements 2.3**

- [ ] 4.4 Write property test for failed rotation
  - **Property 8: Failed rotation preserves state**
  - **Validates: Requirements 2.4**

- [ ] 5. Implement piece falling and locking
  - Implement automatic downward movement with timer
  - Implement lock delay mechanism
  - Implement piece locking to playfield
  - Implement spawn-after-lock logic
  - _Requirements: 1.2, 1.3, 1.4, 1.5_

- [ ] 5.1 Write property test for automatic descent
  - **Property 2: Automatic piece descent**
  - **Validates: Requirements 1.2**

- [ ] 5.2 Write property test for lock delay
  - **Property 3: Lock delay preserves piece state**
  - **Validates: Requirements 1.3**

- [ ] 5.3 Write property test for spawn after lock
  - **Property 4: Spawn after lock**
  - **Validates: Requirements 1.4**

- [ ] 5.4 Write property test for game over condition
  - **Property 5: Game over on blocked spawn**
  - **Validates: Requirements 1.5**

- [ ] 6. Implement line clearing system
  - Implement line completion detection
  - Implement line removal and row collapse
  - _Requirements: 5.1, 5.2_

- [ ] 6.1 Write property test for line clearing
  - **Property 13: Complete rows are cleared**
  - **Validates: Requirements 5.1**

- [ ] 6.2 Write property test for row collapse
  - **Property 14: Rows collapse after line clear**
  - **Validates: Requirements 5.2**

- [ ] 7. Implement scoring and level system
  - Create ScoreManager class
  - Implement score calculation for line clears (with multi-line bonuses)
  - Implement level progression based on lines cleared
  - Implement fall speed calculation based on level
  - _Requirements: 5.3, 5.4, 6.1, 6.2, 8.1, 8.2, 8.3_

- [ ] 7.1 Write property test for score updates
  - **Property 16: Line clears update score**
  - **Validates: Requirements 5.4**

- [ ] 7.2 Write property test for multi-line bonus
  - **Property 15: Multi-line clears award bonus points**
  - **Validates: Requirements 5.3**

- [ ] 7.3 Write property test for level progression
  - **Property 17: Level increases with line threshold**
  - **Validates: Requirements 6.1**

- [ ] 7.4 Write property test for fall speed scaling
  - **Property 18: Higher levels have faster fall speed**
  - **Validates: Requirements 6.2**

- [ ] 8. Implement input handling
  - Create InputHandler class
  - Implement crank rotation detection with threshold
  - Implement D-pad input with auto-repeat
  - Implement button handling (A for hard drop, menu for pause)
  - Add haptic feedback for successful rotations
  - _Requirements: 2.1, 2.2, 2.5, 3.1, 3.2, 3.4, 4.1, 4.2, 4.3, 9.1, 9.3_

- [ ] 8.1 Write property test for soft drop
  - **Property 11: Soft drop increases fall speed**
  - **Validates: Requirements 4.1, 4.2**

- [ ] 8.2 Write property test for hard drop
  - **Property 12: Hard drop moves to lowest position**
  - **Validates: Requirements 4.3**

- [ ] 9. Implement game state management
  - Create GameManager class
  - Implement state machine (menu, playing, paused, gameover)
  - Implement pause/unpause functionality
  - Wire together all game components
  - _Requirements: 9.1, 9.2, 9.3_

- [ ] 9.1 Write property test for pause behavior
  - **Property 20: Pause prevents game updates**
  - **Validates: Requirements 9.2**

- [ ] 9.2 Write property test for pause round trip
  - **Property 21: Pause-unpause round trip**
  - **Validates: Requirements 9.3**

- [ ] 9.3 Write property test for next piece availability
  - **Property 19: Next piece is always available**
  - **Validates: Requirements 7.1**

- [ ] 10. Implement rendering system
  - Create Renderer class
  - Implement playfield grid rendering with boundaries
  - Implement Tetromino rendering with distinct patterns for each type
  - Implement UI rendering (score, level, lines, next piece preview)
  - Implement pause and game over screens
  - _Requirements: 7.1, 8.1, 8.2, 8.3, 9.1, 10.1, 10.2, 10.3_

- [ ] 11. Implement line clear animation
  - Add visual feedback for clearing lines
  - Ensure animation doesn't block game logic
  - _Requirements: 5.5_

- [ ] 12. Integrate all components in main game loop
  - Wire GameManager, InputHandler, and Renderer together
  - Implement playdate.update() function
  - Add FPS counter for performance monitoring
  - _Requirements: 10.4_

- [ ] 13. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 14. Polish and optimization
  - Optimize rendering for consistent 30+ FPS
  - Tune crank rotation sensitivity
  - Adjust timing values (lock delay, auto-repeat rates)
  - Add sound effects (if time permits)
  - _Requirements: 10.3, 10.4_

- [ ] 15. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

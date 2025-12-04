# Requirements Document

## Introduction

This document specifies the requirements for a Tetris game implementation for the Playdate handheld console. The game follows classic Tetris mechanics with flexible input options: players can use the Playdate's physical crank to rotate falling pieces for a tactile experience, or use the B button for traditional button-based rotation. The game must run efficiently on the Playdate hardware and support both input methods while maintaining the core Tetris gameplay that players expect.

## Glossary

- **Tetris Game**: The game system that manages all game state, logic, and rendering
- **Tetromino**: A geometric shape composed of four square blocks connected orthogonally (the falling pieces in Tetris)
- **Playfield**: A 10-column by 20-row grid where Tetrominos fall and stack
- **Crank**: The physical rotating input device on the side of the Playdate console
- **Lock Delay**: The brief period after a Tetromino touches the bottom or another piece before it locks into place
- **Line Clear**: The removal of a completed horizontal row of blocks from the Playfield
- **Playdate SDK**: The software development kit provided by Panic for developing Playdate games

## Requirements

### Requirement 1

**User Story:** As a player, I want Tetrominos to spawn at the top of the playfield and fall downward, so that I can play the core Tetris gameplay loop.

#### Acceptance Criteria

1. WHEN the game starts THEN the Tetris Game SHALL spawn a random Tetromino at the top center of the Playfield
2. WHILE a Tetromino is active THEN the Tetris Game SHALL move the Tetromino downward by one row at regular time intervals
3. WHEN a Tetromino cannot move downward THEN the Tetris Game SHALL lock the Tetromino into the Playfield after the Lock Delay expires
4. WHEN a Tetromino locks into place THEN the Tetris Game SHALL spawn a new random Tetromino at the top of the Playfield
5. WHEN the spawn location is blocked by existing blocks THEN the Tetris Game SHALL end the game

### Requirement 2

**User Story:** As a player, I want to rotate Tetrominos using the Playdate crank or the B button, so that I can position pieces using either the console's unique input method or traditional button controls.

#### Acceptance Criteria

1. WHEN the player rotates the Crank clockwise THEN the Tetris Game SHALL rotate the active Tetromino 90 degrees clockwise
2. WHEN the player rotates the Crank counter-clockwise THEN the Tetris Game SHALL rotate the active Tetromino 90 degrees counter-clockwise
3. WHEN the player presses the B button THEN the Tetris Game SHALL rotate the active Tetromino 90 degrees clockwise
4. WHEN a rotation would cause the Tetromino to overlap existing blocks or exceed Playfield boundaries THEN the Tetris Game SHALL attempt wall kick adjustments
5. WHEN wall kick adjustments fail THEN the Tetris Game SHALL prevent the rotation and maintain the current orientation
6. WHEN a rotation is successful via the Crank THEN the Tetris Game SHALL provide haptic feedback through the Crank

### Requirement 3

**User Story:** As a player, I want to move Tetrominos horizontally using the D-pad, so that I can position pieces precisely in the playfield.

#### Acceptance Criteria

1. WHEN the player presses the left D-pad button THEN the Tetris Game SHALL move the active Tetromino one column to the left
2. WHEN the player presses the right D-pad button THEN the Tetris Game SHALL move the active Tetromino one column to the right
3. WHEN a horizontal movement would cause the Tetromino to overlap existing blocks or exceed Playfield boundaries THEN the Tetris Game SHALL prevent the movement
4. WHILE the player holds a horizontal D-pad button THEN the Tetris Game SHALL repeat the movement at a controlled rate after an initial delay

### Requirement 4

**User Story:** As a player, I want to drop Tetrominos quickly, so that I can speed up gameplay when I've decided on piece placement.

#### Acceptance Criteria

1. WHILE the player holds the down D-pad button THEN the Tetris Game SHALL increase the downward movement speed of the active Tetromino
2. WHEN the player releases the down D-pad button THEN the Tetris Game SHALL return the Tetromino to normal falling speed
3. WHEN the player presses the A button THEN the Tetris Game SHALL instantly drop the active Tetromino to the lowest valid position and lock it immediately

### Requirement 5

**User Story:** As a player, I want completed lines to clear and award points, so that I have a goal to work toward and can track my progress.

#### Acceptance Criteria

1. WHEN a horizontal row in the Playfield is completely filled with blocks THEN the Tetris Game SHALL perform a Line Clear on that row
2. WHEN a Line Clear occurs THEN the Tetris Game SHALL remove the completed row and move all rows above it downward by one row
3. WHEN multiple rows are cleared simultaneously THEN the Tetris Game SHALL award more points than clearing single rows
4. WHEN a Line Clear occurs THEN the Tetris Game SHALL update the displayed score based on the number of lines cleared
5. WHEN lines are cleared THEN the Tetris Game SHALL provide visual feedback showing the clearing animation

### Requirement 6

**User Story:** As a player, I want the game difficulty to increase over time, so that the game remains challenging as I improve.

#### Acceptance Criteria

1. WHEN the player clears a specified number of lines THEN the Tetris Game SHALL increase the level
2. WHEN the level increases THEN the Tetris Game SHALL decrease the time interval between automatic downward movements
3. WHEN the level changes THEN the Tetris Game SHALL display the new level to the player

### Requirement 7

**User Story:** As a player, I want to see the next Tetromino that will spawn, so that I can plan my moves strategically.

#### Acceptance Criteria

1. WHEN the game is running THEN the Tetris Game SHALL display a preview of the next Tetromino in a designated area
2. WHEN a new Tetromino spawns THEN the Tetris Game SHALL update the preview to show the following Tetromino

### Requirement 8

**User Story:** As a player, I want to see my current score, level, and lines cleared, so that I can track my performance.

#### Acceptance Criteria

1. WHEN the game is running THEN the Tetris Game SHALL continuously display the current score
2. WHEN the game is running THEN the Tetris Game SHALL continuously display the current level
3. WHEN the game is running THEN the Tetris Game SHALL continuously display the total number of lines cleared

### Requirement 9

**User Story:** As a player, I want to pause and resume the game, so that I can take breaks without losing my progress.

#### Acceptance Criteria

1. WHEN the player presses the menu button during gameplay THEN the Tetris Game SHALL pause all game logic and display a pause indicator
2. WHILE the game is paused THEN the Tetris Game SHALL not update Tetromino positions or spawn new pieces
3. WHEN the player presses the menu button while paused THEN the Tetris Game SHALL resume normal gameplay

### Requirement 10

**User Story:** As a player, I want the game to render clearly on the Playdate's black and white screen, so that I can easily distinguish all game elements.

#### Acceptance Criteria

1. WHEN rendering the Playfield THEN the Tetris Game SHALL draw clear boundaries and grid lines
2. WHEN rendering Tetrominos THEN the Tetris Game SHALL use distinct patterns or fills to differentiate piece types
3. WHEN rendering the game interface THEN the Tetris Game SHALL use high-contrast graphics suitable for the monochrome display
4. WHEN the game updates THEN the Tetris Game SHALL maintain a frame rate of at least 30 frames per second

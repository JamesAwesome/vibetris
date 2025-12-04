# Requirements Document

## Introduction

This feature involves rebranding the Playdate Tetris game to "Vibetris" and creating a custom bubble letter logo for the game's start screen. The rebrand will update all references throughout the codebase, file structure, and documentation while maintaining the existing game functionality. A new visual identity will be established through a custom logo displayed on the start screen.

## Glossary

- **Game**: The Playdate Tetris application being rebranded to Vibetris
- **Logo**: A graphical representation of the word "Vibetris" in bubble letter style
- **Start Screen**: The initial screen displayed when the Game launches, before gameplay begins
- **Bubble Letters**: A stylized font design where letters appear rounded and three-dimensional, resembling bubbles
- **Playdate**: The handheld gaming console platform for which the Game is developed
- **PDX**: Playdate executable format, the compiled game package
- **Rockspec**: Lua package specification file used for dependency management

## Requirements

### Requirement 1

**User Story:** As a player, I want to see the game branded as "Vibetris" instead of "Tetris", so that the game has a unique identity.

#### Acceptance Criteria

1. WHEN the Game launches THEN the system SHALL display "Vibetris" as the game title on the start screen
2. WHEN a user views the game files THEN the system SHALL use "Vibetris" in all file names, directory names, and package identifiers
3. WHEN a user reads documentation THEN the system SHALL reference "Vibetris" consistently throughout all documentation files
4. WHEN the Game is compiled THEN the system SHALL generate a PDX package named "Vibetris.pdx"
5. WHEN a user views the Playdate menu THEN the system SHALL display "Vibetris" as the application name

### Requirement 2

**User Story:** As a player, I want to see an attractive bubble letter logo for "Vibetris" on the start screen, so that the game has a distinctive visual identity.

#### Acceptance Criteria

1. WHEN the start screen is displayed THEN the system SHALL render the Logo in bubble letter style
2. WHEN the Logo is rendered THEN the system SHALL position it prominently on the start screen
3. WHEN the Logo is displayed THEN the system SHALL use a design that is clearly readable on the Playdate's monochrome display
4. WHEN the Game transitions from the start screen THEN the system SHALL remove or fade out the Logo appropriately
5. WHEN the Logo is created THEN the system SHALL store it in an appropriate image format compatible with the Playdate SDK

### Requirement 3

**User Story:** As a developer, I want all code references updated from "Tetris" to "Vibetris", so that the codebase is consistent with the new branding.

#### Acceptance Criteria

1. WHEN the codebase is searched for "tetris" (case-insensitive) THEN the system SHALL return only intentional references (if any) and no outdated branding
2. WHEN Lua modules are loaded THEN the system SHALL use "vibetris" in module paths and identifiers where appropriate
3. WHEN the Game initializes THEN the system SHALL use "Vibetris" in any internal configuration or metadata
4. WHEN tests are executed THEN the system SHALL reference "Vibetris" in test descriptions and assertions where the game name appears
5. WHEN the Rockspec is processed THEN the system SHALL identify the package as "vibetris"

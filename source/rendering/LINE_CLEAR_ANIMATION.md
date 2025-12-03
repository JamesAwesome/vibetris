# Line Clear Animation Implementation

## Overview

The line clear animation provides visual feedback when lines are cleared in Tetris. The animation flashes the cleared lines for 300ms before removing them, without blocking game logic.

## Implementation Details

### Animation State (GameManager)

The GameManager tracks animation state with three properties:
- `clearingLines`: Array of line indices being cleared (nil when not animating)
- `clearAnimationTimer`: Current animation progress (0 to clearAnimationDuration)
- `clearAnimationDuration`: Total animation time (0.3 seconds)

### Animation Flow

1. **Detection**: When lines are detected in `updatePlaying()`, instead of immediately clearing them, `startClearAnimation()` is called
2. **Animation**: While `clearingLines` is not nil, the game enters animation mode:
   - Game logic is paused (pieces don't fall, input is ignored)
   - Animation timer increments each frame
   - Renderer displays flashing effect on cleared lines
3. **Completion**: When timer reaches duration:
   - Lines are actually cleared from the playfield
   - Score is updated
   - Fall speed is recalculated
   - Animation state is reset

### Visual Effect (Renderer)

The renderer creates a flashing effect by:
- Checking if each block is in a line being cleared
- Calculating flash phase based on animation progress (6 flashes = 3 full on/off cycles)
- Alternating between normal pattern rendering and white fill
- Maintaining block outlines throughout

### Key Design Decisions

1. **Non-blocking**: Animation runs in the game loop without blocking other systems
2. **State-based**: Animation state is cleanly separated from game state
3. **Configurable**: Animation duration can be easily adjusted
4. **Visual clarity**: Flashing effect is clear on monochrome display
5. **Pause during animation**: Game logic pauses to let player see what happened

## Files Modified

- `source/game/manager.lua`: Added animation state and control logic
- `source/rendering/init.lua`: Added animation rendering with flashing effect

## Testing

Unit tests verify:
- Animation starts when lines are detected
- Animation completes and clears lines properly
- Game logic pauses during animation
- Multiple lines can be animated simultaneously

All existing property-based tests continue to pass.

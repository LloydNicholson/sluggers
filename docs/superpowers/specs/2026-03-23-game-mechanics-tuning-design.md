# Game Mechanics Tuning Design
**Date:** 2026-03-23
**Project:** Sluggers (Godot 2-player PvP game)
**Audience:** 4-year-old children + casual play

## Overview
Tune core gameplay mechanics and visuals to provide responsive, satisfying controls for young children with clear feedback systems.

## 1. Player Movement

### Current State
- Friction coefficient: 0.2 (minimal friction)
- Players slide significantly when releasing input
- Movement feels slippery and hard to control precisely

### Target
- High friction (~0.6-0.7) for planted, responsive feel
- Stop quickly when releasing movement input
- Predictable, easy-to-control movement

### Implementation
- Increase `FRICTION_COEFF` in `Player.gd` from 0.2 to 0.6-0.7
- Test and tune exact value based on playtest feedback
- Maintain existing acceleration (1800 px/s²) for responsive input

### Rationale
Young children need predictable, responsive controls. High friction eliminates the "ice skating" feel and makes movement intuitive.

---

## 2. Jump Mechanics

### Current State
- Jump speed: -840 px/s
- Max jump height: ~122 px (apex roughly 60% of room height)
- Players can jump nearly the full height of the room
- **Problem:** Can potentially jump across the 200px chasm in Room0

### Target
- Max jump height: ~60-70 px (safely prevent chasm crossing)
- Maintain variable jump height (button press duration)
- Ensure horizontal distance cannot exceed 200px chasm width

### Physics Calculation
Room0 chasm width: 200px (floor gap from x=284 to x=484)

With gravity 2880 px/s², to achieve 60-70px height:
- Required JUMP_SPEED: -590 to -610 px/s
- Time to apex: ~0.2 seconds
- Max horizontal distance (at 600 px/s): ~120px
- **Chasm cannot be crossed ✓**

### Implementation
- Set `JUMP_SPEED` in `Player.gd` to **-600** (gives ~62.5px height)
- Adjust `MIN_JUMP_SPEED` from -336 to approximately **-240** (40% of new JUMP_SPEED)
- Confirm with playtesting that jump feels good and chasm is uncrossable

### Rationale
Jump height and horizontal distance are mathematically tied to gravity and max speed. The -600 value balances fun platforming feel with level design constraints—tall enough to be satisfying for young children, but safely prevents jumping over the chasm middle.

---

## 3. Bubble Gun Visual Positioning

### Current State
- Gun sprite positioned at y = -14.0
- Appears to originate from player's lower body/crotch area

### Target
- Move gun sprite up to y = -20.0 to -22.0
- Appears to originate from hand/shoulder level

### Implementation
- Update gun sprite position in `Player.gd` line 106: `Vector2(8.0, -14.0)` → `Vector2(8.0, -20.0)`
- Test visually; adjust by 2px increments if needed

### Rationale
Proper visual positioning improves readability and makes the gun feel like a held weapon rather than an appendage. Important for clarity when playing with young children.

---

## 4. Bubble Projectile Movement

### Current State
- Constant sinusoidal wave: amplitude 18px, frequency 2.5 Hz
- Creates pronounced up-down oscillation
- Feels erratic and hard to predict

### Target
- Smooth, subtle wobbles instead of pronounced waves
- Slight unpredictability but visually readable trajectory
- Maintains forward movement and gentle upward drift

### Implementation
- Reduce `WAVE_AMPLITUDE` in `Bubble.gd` from 18.0 to ~8.0-10.0
- Keep `WAVE_FREQUENCY` at 2.5 (or reduce slightly to 2.0 for smoother motion)
- Keep `SPEED` at 200 px/s and `UPWARD_DRIFT` at 20 px/s

### Rationale
Smaller amplitude creates less erratic motion while still providing visual interest. Easier for children to anticipate bubble trajectory.

---

## 5. Bubble Trap Mechanic - Visual Bubble

### Current State
- No visual bubble graphic around trapped player
- Only color tint (blue pulse) indicates trapped state
- Unclear what "trapped" means to a young child

### Target
- Large visual bubble (~2x player size) appears around and contains the trapped player
- Bobbing animation while floating upward (gentle up-down motion)
- Clear visual feedback that player is trapped

### Implementation
**New Asset:** Create or source a bubble sprite (~64-72px diameter for 2x player)
**Scene Structure:** Add a `Bubble2D` node as visual container around trapped player
**Animation:** Apply gentle bobbing tween or animation while in BUBBLED state
- Y position oscillates by ~8-12px with ~1 second period
- Player position updates match bubble bobbing

**Physics:** Maintain current `_tick_bubble()` behavior (upward float, escape mashing)

### Rationale
Visual representation makes the mechanic immediately understandable. Bobbing motion reinforces that the bubble is "floating upward." Helps children understand cause-and-effect.

---

## 6. Bubble Escape UI

### Current State
- Players can mash any face button to escape (5 hits required)
- No visual indication of which button to press or progress

### Target
- Clear on-screen button prompt showing which button(s) to mash
- Visual feedback showing escape progress (e.g., mash counter or fill bar)
- Easy for children to understand what action is required

### Implementation
**UI Element:** Add a Canvas Layer with centered prompt near trapped player
**Button Display:** Show A, B, X, or Y button icon with text "MASH TO ESCAPE"
**Progress Indicator:** Display escape meter (e.g., "2/5" or visual bar) updated each button press
**Bobbing Sync:** UI follows player/bubble bobbing motion

### Rationale
Young children need explicit instruction. Visual button prompt removes ambiguity. Progress meter provides satisfying feedback during escape sequence.

---

## 7. Bubble Ceiling Collision (NEW)

### Current State
- Bubble stops detecting collisions when player inside
- No ceiling interaction mechanic

### Target
- Bubble bursts when it hits the ceiling (or any solid object)
- Releases trapped player
- Visual/audio feedback on burst

### Implementation
**Modify `_tick_bubble()` in `Player.gd`:**
- Check for collision with world geometry while BUBBLED state
- On ceiling hit, trigger `_exit_bubble()` and play burst effect
- Consider: Knockback or simple state reset on burst

**Visual/Audio:**
- Particle effect or sprite animation for bubble pop
- Pop sound effect (if audio is desired)

**Behavior:** Player transitions to AIR state on burst, applies mild upward knockback if desired

### Rationale
Adds strategic element: ceiling height becomes a natural "safe zone" mechanic. Prevents infinite floating and gives players agency in escape strategy beyond mashing buttons.

---

## Constants Summary (Quick Reference)

| Constant | Current | Target | File |
|----------|---------|--------|------|
| FRICTION_COEFF | 0.2 | 0.6-0.7 | Player.gd:24 |
| JUMP_SPEED | -840 | **-600** | Player.gd:26 |
| MIN_JUMP_SPEED | -336 | **-240** | Player.gd:27 |
| Gun Y position | -14.0 | -20.0 | Player.gd:106 |
| WAVE_AMPLITUDE | 18.0 | 8.0-10.0 | Bubble.gd:13 |
| WAVE_FREQUENCY | 2.5 | 2.0-2.5 | Bubble.gd:15 |

---

## Testing Checklist
- [ ] Movement feels planted and responsive
- [ ] Jump height is ~60-70px max
- [ ] Gun sprite visually positioned at hand level
- [ ] Bubble trajectory is smooth with subtle wobbles
- [ ] Trapped player animation shows clear bobbing
- [ ] Escape button prompt is visible and understandable
- [ ] Escape progress meter updates on button press
- [ ] Bubble pops on ceiling collision
- [ ] Overall gameplay is fun and accessible for 4-year-olds

---

## Notes
- Tuning values are estimates; actual values should be tested and adjusted based on playtest feel
- Consider adding sound effects (gun pop, bubble burst, button mash feedback) in follow-up iteration
- Particle effects can be simple (colored circles/squares) for performance on lower-end devices

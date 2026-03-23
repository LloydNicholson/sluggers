# Game Mechanics Tuning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tune player physics, visual positioning, and bubble trap mechanics to create responsive, child-friendly gameplay with clear feedback systems.

**Architecture:** Changes span three main areas:

1. **Physics constants** in Player.gd (friction, jump height) and Bubble.gd (projectile wobble)
2. **Visual positioning** (gun sprite, bubble trap graphics) and animations (bobbing effect)
3. **Interaction systems** (ceiling collision detection, escape UI feedback)

These changes maintain existing code structure while adding new visual/animation systems and collision logic.

**Tech Stack:** Godot 4.x, GDScript, Tweens for animations, CanvasLayer for UI overlay

---

## File Structure

**Modified files:**

- `godot/scenes/player/Player.gd` - Physics constants, gun positioning, trap visual/animation, ceiling collision logic
- `godot/scenes/objects/Bubble.gd` - Projectile movement parameters
- `godot/scenes/player/Player.tscn` - (visual only, no scene changes needed)

**Approach:** All changes are contained modifications to existing systems. No new scenes created; bubble trap visual, animation, and UI are created at runtime when player enters BUBBLED state.

---

## Task 1: Adjust Player Physics Constants

**Files:**

- Modify: `godot/scenes/player/Player.gd:20-27`

**Goal:** Update friction and jump parameters for responsive, weighted gameplay that prevents chasm crossing.

- [ ] **Step 1: Update FRICTION_COEFF**

Open `godot/scenes/player/Player.gd` and change line 24:

```gdscript
const FRICTION_COEFF: float      = 0.6  # Increased from 0.2 for planted feel
```

- [ ] **Step 2: Update JUMP_SPEED**

Change line 26:

```gdscript
const JUMP_SPEED: float          = -600.0   # Reduced from -840; apex ≈ 62 px (safe chasm)
```

Update the comment on the next line to reflect the new height.

- [ ] **Step 3: Update MIN_JUMP_SPEED**

Change line 27:

```gdscript
const MIN_JUMP_SPEED: float      = -240.0   # 40% of new JUMP_SPEED (was -336)
```

- [ ] **Step 4: Playtest movement feel**

Run the game, move around on the left/right platforms. Movement should feel planted with quick stops. Jump once—should reach about halfway up the screen. Try to jump across the middle chasm—should NOT be able to reach the other side.

Expected: Players stop quickly when releasing input. Jump apex is visibly lower than before. Cannot cross chasm.

- [ ] **Step 5: Commit**

```bash
git add godot/scenes/player/Player.gd
git commit -m "tune: increase friction and reduce jump height for responsive child-friendly controls

- FRICTION_COEFF 0.2 → 0.6 (planted, responsive movement)
- JUMP_SPEED -840 → -600 (62px max height, prevents chasm crossing)
- MIN_JUMP_SPEED -336 → -240 (maintains variable jump height)"
```

---

## Task 2: Adjust Bubble Gun Position

**Files:**

- Modify: `godot/scenes/player/Player.gd:106`

**Goal:** Move gun sprite from lower body to hand/shoulder level.

- [ ] **Step 1: Update gun position**

In `Player.gd`, find the `_ready()` function around line 106. Change:

```gdscript
_gun_sprite.position = Vector2(8.0, -20.0)  # Changed from -14.0 to -20.0
```

- [ ] **Step 2: Playtest visual positioning**

Run the game. Observe the bubble gun sprite on the player. It should now appear at the player's hand/shoulder level instead of lower body.

Expected: Gun sprite visually originates from the player's upper torso/hand area.

- [ ] **Step 3: Commit**

```bash
git add godot/scenes/player/Player.gd
git commit -m "tune: move bubble gun sprite to hand/shoulder level

Gun sprite y position adjusted from -14.0 to -20.0 for better visual clarity."
```

---

## Task 3: Reduce Bubble Projectile Wave Amplitude

**Files:**

- Modify: `godot/scenes/objects/Bubble.gd:13-14`

**Goal:** Create smoother, more subtle projectile movement instead of pronounced oscillation.

- [ ] **Step 1: Update WAVE_AMPLITUDE**

Open `godot/scenes/objects/Bubble.gd` and change line 13:

```gdscript
const WAVE_AMPLITUDE := 10.0  # Reduced from 18.0 for smoother trajectory
```

- [ ] **Step 2: Update WAVE_FREQUENCY (optional)**

Consider reducing line 15 slightly for even smoother motion:

```gdscript
const WAVE_FREQUENCY := 2.0  # Reduced from 2.5 for gentler wobble (optional)
```

- [ ] **Step 3: Playtest bubble projectile**

Run the game. Fire a bubble (press B on gamepad). Observe the bubble's path—should have subtle wobbles rather than pronounced up-down oscillation.

Expected: Bubble travels in a gently wavy path. Less erratic, more readable trajectory.

- [ ] **Step 4: Commit**

```bash
git add godot/scenes/objects/Bubble.gd
git commit -m "tune: reduce bubble projectile wave amplitude for smoother motion

- WAVE_AMPLITUDE 18.0 → 10.0 (subtle wobbles)
- WAVE_FREQUENCY 2.5 → 2.0 (gentler oscillation)"
```

---

## Task 4: Create Bubble Trap Visual (Circle Around Player)

**Files:**

- Modify: `godot/scenes/player/Player.gd:1-50, 200-230`

**Goal:** Display a large visual bubble (~2x player size) around trapped player to make the trap state obvious.

- [ ] **Step 1: Add bubble visual sprite reference**

In `Player.gd`, add a new member variable around line 90:

```gdscript
var _bubble_trap_visual: Node2D = null
```

- [ ] **Step 2: Create bubble visual when entering BUBBLED state**

In the `enter_bubble()` function (around line 352), add code to create the visual after line 358:

```gdscript
func enter_bubble() -> void:
 """Called by a Bubble projectile when it hits this player."""
 if _state == State.DEAD or _state == State.BUBBLED:
  return
 _state = State.BUBBLED
 _bubble_hits = 0
 _bubble_timer = 0.0
 velocity = Vector2.ZERO

 # Create visual bubble around player
 _bubble_trap_visual = Sprite2D.new()
 _bubble_trap_visual.position = Vector2(0, -14)
 # Use the existing bubble sprite, scaled up 3x
 _bubble_trap_visual.texture = load("res://assets/sprites/s_bubble.png")
 _bubble_trap_visual.scale = Vector2(3.0, 3.0)  # Scale up the bubble sprite 3x
 _bubble_trap_visual.modulate = Color(0.6, 0.85, 1.0, 0.7)  # Light blue tint
 _bubble_trap_visual.z_index = -1  # Behind player
 add_child(_bubble_trap_visual)
```

- [ ] **Step 3: Remove bubble visual when exiting BUBBLED state**

In `_exit_bubble()` function (around line 362), add cleanup:

```gdscript
func _exit_bubble() -> void:
 _state = State.AIR
 if _sprite:
  _sprite.modulate = Color.WHITE
 if _bubble_trap_visual:
  _bubble_trap_visual.queue_free()
  _bubble_trap_visual = null
```

- [ ] **Step 4: Playtest trap visual**

Run the game. Have one player shoot a bubble at the other. When hit, a large blue circle should appear around the trapped player.

Expected: Large translucent blue circle (~2x player size) is visible around trapped player.

- [ ] **Step 5: Commit**

```bash
git add godot/scenes/player/Player.gd
git commit -m "feat: add visual bubble around trapped player

- Create large semi-transparent blue circle when entering BUBBLED state
- Circle is ~2x player size (scale 3.0) for clear visibility
- Cleanup visual on bubble escape"
```

---

## Task 5: Add Bubble Bobbing Animation

**Files:**

- Modify: `godot/scenes/player/Player.gd:209-228`

**Goal:** Animate bubble visual with gentle up-down bobbing while floating upward.

- [ ] **Step 1: Create bobbing tween in _tick_bubble()**

Modify the `_tick_bubble()` function. After the state check, add bobbing animation:

```gdscript
func _tick_bubble(delta: float) -> void:
 if _bubble_timer == 0.0 and _bubble_trap_visual:
  # Start bobbing animation (runs continuously)
  var tween = create_tween()
  tween.set_loops()  # Loop infinitely
  tween.set_trans(Tween.TRANS_SINE)
  tween.set_ease(Tween.EASE_IN_OUT)
  tween.tween_property(_bubble_trap_visual, "position:y", -14.0 - 10.0, 0.8)
  tween.tween_property(_bubble_trap_visual, "position:y", -14.0 + 10.0, 0.8)

 _bubble_timer += delta
 # Float gently upward; no horizontal control.
 velocity.x = 0.0
 velocity.y = BUBBLE_FLOAT_VY
 move_and_slide()
 # Mash any face button to escape.
 if _joy_any_face():
  _bubble_hits += 1
  if _bubble_hits >= BUBBLE_ESCAPE_HITS:
   _exit_bubble()
   return
 # Auto-escape after timeout.
 if _bubble_timer >= BUBBLE_MAX_DURATION:
  _exit_bubble()
 # Pulse blue tint while trapped.
 if _sprite:
  var pulse := 0.6 + 0.4 * absf(sin(_bubble_timer * 4.0))
  _sprite.modulate = Color(0.4, 0.7, 1.0, pulse)
```

- [ ] **Step 2: Playtest bobbing animation**

Run the game. Trap a player in a bubble. The bubble should gently bob up and down while the player floats upward.

Expected: Bubble visual gently oscillates up/down with a ~1.6 second period (0.8s up, 0.8s down).

- [ ] **Step 3: Commit**

```bash
git add godot/scenes/player/Player.gd
git commit -m "feat: add gentle bobbing animation to trapped bubble

- Bubble visual bobs up/down with sine curve (0.8s period)
- Animation loops while player is trapped
- Creates pleasant floating effect"
```

---

## Task 6: Add Escape Button UI Prompt

**Files:**

- Modify: `godot/scenes/player/Player.gd:60-75, 352-366`

**Goal:** Display clear on-screen prompt showing which button to mash and escape progress.

- [ ] **Step 1: Add UI control references**

In `Player.gd`, add members around line 90:

```gdscript
var _escape_prompt_label: Label = null
var _escape_progress_bar: ProgressBar = null
```

- [ ] **Step 2: Create UI when entering BUBBLED state**

In `enter_bubble()`, after creating the bubble visual, add:

```gdscript
 # Create escape prompt UI
 _escape_prompt_label = Label.new()
 _escape_prompt_label.text = "MASH B BUTTON"
 _escape_prompt_label.add_theme_font_size_override("font_size", 24)
 _escape_prompt_label.position = Vector2(-80, -60)
 add_child(_escape_prompt_label)

 # Create progress bar
 _escape_progress_bar = ProgressBar.new()
 _escape_progress_bar.min_value = 0
 _escape_progress_bar.max_value = float(BUBBLE_ESCAPE_HITS)
 _escape_progress_bar.value = 0
 _escape_progress_bar.size = Vector2(80, 16)
 _escape_progress_bar.position = Vector2(-40, -35)
 add_child(_escape_progress_bar)
```

- [ ] **Step 3: Update progress bar in _tick_bubble()**

In `_tick_bubble()`, update the progress bar when button is pressed:

```gdscript
 # Mash any face button to escape.
 if _joy_any_face():
  _bubble_hits += 1
  if _escape_progress_bar:
   _escape_progress_bar.value = float(_bubble_hits)
  if _bubble_hits >= BUBBLE_ESCAPE_HITS:
   _exit_bubble()
   return
```

- [ ] **Step 4: Clean up UI on exit**

In `_exit_bubble()`, add cleanup:

```gdscript
 if _escape_prompt_label:
  _escape_prompt_label.queue_free()
  _escape_prompt_label = null
 if _escape_progress_bar:
  _escape_progress_bar.queue_free()
  _escape_progress_bar = null
```

- [ ] **Step 5: Playtest UI**

Run the game. Trap a player. A "MASH B BUTTON" label and progress bar should appear. Mash B—progress bar should fill. When full, player escapes.

Expected: Clear button prompt and visual progress indicator. Progress bar fills with each button press.

- [ ] **Step 6: Commit**

```bash
git add godot/scenes/player/Player.gd
git commit -m "feat: add escape UI prompt and progress indicator

- Display \"MASH B BUTTON\" label above trapped player
- Show progress bar filling on each button mash
- Clear UI when player escapes bubble"
```

---

## Task 7: Add Bubble Ceiling Collision Detection

**Files:**

- Modify: `godot/scenes/player/Player.gd:209-228`

**Goal:** Detect when bubble hits ceiling and burst (release player).

- [ ] **Step 1: Add ceiling detection to _tick_bubble()**

Modify `_tick_bubble()` to check for collisions with world geometry:

```gdscript
func _tick_bubble(delta: float) -> void:
 if _bubble_timer == 0.0 and _bubble_trap_visual:
  # Start bobbing animation
  var tween = create_tween()
  tween.set_loops()
  tween.set_trans(Tween.TRANS_SINE)
  tween.set_ease(Tween.EASE_IN_OUT)
  tween.tween_property(_bubble_trap_visual, "position:y", -14.0 - 10.0, 0.8)
  tween.tween_property(_bubble_trap_visual, "position:y", -14.0 + 10.0, 0.8)

 _bubble_timer += delta
 # Float gently upward; no horizontal control.
 velocity.x = 0.0
 velocity.y = BUBBLE_FLOAT_VY
 move_and_slide()

 # Check for ceiling collision
 if is_on_ceiling():
  _burst_bubble()
  return

 # Mash any face button to escape.
 if _joy_any_face():
  _bubble_hits += 1
  if _escape_progress_bar:
   _escape_progress_bar.value = float(_bubble_hits)
  if _bubble_hits >= BUBBLE_ESCAPE_HITS:
   _exit_bubble()
   return

 # Auto-escape after timeout.
 if _bubble_timer >= BUBBLE_MAX_DURATION:
  _exit_bubble()
  return

 # Pulse blue tint while trapped.
 if _sprite:
  var pulse := 0.6 + 0.4 * absf(sin(_bubble_timer * 4.0))
  _sprite.modulate = Color(0.4, 0.7, 1.0, pulse)
```

- [ ] **Step 2: Create _burst_bubble() function**

Add new function after `_exit_bubble()`:

```gdscript
func _burst_bubble() -> void:
 """Bubble hits ceiling or obstacle and bursts, releasing player."""
 _state = State.AIR
 velocity.y = -120.0  # Small upward bounce on burst
 if _sprite:
  _sprite.modulate = Color.WHITE
 if _bubble_trap_visual:
  _bubble_trap_visual.queue_free()
  _bubble_trap_visual = null
 if _escape_prompt_label:
  _escape_prompt_label.queue_free()
  _escape_prompt_label = null
 if _escape_progress_bar:
  _escape_progress_bar.queue_free()
  _escape_progress_bar = null
```

- [ ] **Step 3: Playtest ceiling collision**

Run the game. Trap a player in a bubble. Let them float up until they hit the ceiling. The bubble should pop/disappear and the player should be released.

Expected: When bubble reaches ceiling, it bursts, player is released and gets small upward bounce.

- [ ] **Step 4: Commit**

```bash
git add godot/scenes/player/Player.gd
git commit -m "feat: bubble bursts when hitting ceiling

- Add ceiling collision detection in BUBBLED state
- Player bounces slightly upward on burst
- Cleanup all bubble visuals/UI on burst"
```

---

## Task 8: Full Playtesting and Polish

**Files:**

- Test: All modified files via in-game playtesting

**Goal:** Verify all changes work together, feel good, and are child-friendly.

- [ ] **Step 1: Test all mechanics together**

Run the game with both players. Test:

- [ ] Movement feels planted and responsive (no sliding)
- [ ] Jump height is reasonable (~60px max, cannot cross chasm)
- [ ] Gun sprite positioned at hand level
- [ ] Bubble projectile has subtle wobbles (not erratic)
- [ ] Bubble trap visual is clear and large
- [ ] Bobbing animation is gentle and continuous
- [ ] Escape prompt is visible and understandable
- [ ] Mashing B button makes progress visible
- [ ] Bubble bursts on ceiling hit
- [ ] Overall gameplay is fun for young children

- [ ] **Step 2: Adjust tuning values if needed**

If playtesting reveals issues:

- Movement too stiff? Reduce FRICTION_COEFF slightly (try 0.55)
- Jump too low/high? Adjust JUMP_SPEED in 50px increments
- Bubble visual too small/large? Adjust scale value
- Bobbing too fast/slow? Adjust tween duration (0.8 → 0.6/1.0)
- Progress bar fills too quickly? Increase BUBBLE_ESCAPE_HITS

Re-test after adjustments.

- [ ] **Step 3: Final commit (if adjustments made)**

```bash
git add godot/scenes/player/Player.gd
git commit -m "tune: final playtesting adjustments for child-friendly feel"
```

---

## Summary

**Total changes:**

- 2 files modified (Player.gd, Bubble.gd)
- 8 physics/visual/UI parameters adjusted
- New visual and animation systems added
- New ceiling collision mechanic implemented
- All changes maintain existing code structure
- Frequent commits (8+ steps) for easy review/rollback

**Estimated playtesting time:** 30-45 minutes
**Rollback safety:** Each commit is independently testable

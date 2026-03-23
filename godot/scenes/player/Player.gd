extends CharacterBody2D

## Sluggers – Player (v2)
##
## Two-player same-screen PvP edition. Each player instance is bound to a
## separate physical controller via `controller_device` (0 = P1, 1 = P2).
## All per-player input uses raw joypad polling so each device is isolated.
##
## States:
##   GROUND  – walking, friction-based deceleration
##   AIR     – in-flight (coyote time + jump buffering)
##   WALL    – sliding, reduced friction + wall-jump
##   DEAD    – death animation, auto-respawn
##   BUBBLED – trapped in a bubble; floats upward until mash-escaped
##
## Jump tuning: JUMP_SPEED set to -600.0 (apex ~62 px, half room height, prevents chasm)
## MIN_JUMP_SPEED at 40% for variable jump height.

# ── Physics constants ──────────────────────────────────────────────────────
const GRAVITY: float             = 2880.0   # px/s²
const MAX_FALL_SPEED: float      = 1200.0   # px/s
const MAX_SPEED: float           = 300.0    # px/s (reduced for child-friendly slow movement)
const ACCELERATION: float        = 1800.0   # px/s² (used with delta)
const FRICTION_COEFF: float      = 0.5   # Very high friction for very slow, controlled movement
const WALL_FRICTION_COEFF: float = 0.08
const JUMP_SPEED: float          = -600.0   # apex ≈ 62 px (prevents chasm crossing)
const MIN_JUMP_SPEED: float      = -240.0   # 40 % of JUMP_SPEED (variable height)
const WALL_JUMP_H: float         = 480.0
const WALL_JUMP_V: float         = -960.0

# ── Platforming-feel constants ─────────────────────────────────────────────
const COYOTE_TIME: float         = 0.12
const JUMP_BUFFER_TIME: float    = 0.12
const WALL_JUMP_LOCK_TIME: float = 0.25

# ── Combat constants ───────────────────────────────────────────────────────
const KNOCKBACK_H: float         = 360.0
const KNOCKBACK_V: float         = -360.0
const IFRAMES_DURATION: float    = 1.2
const STOMP_MIN_VY: float        = 50.0
const STOMP_BOUNCE: float        = -600.0
const DEATH_RESPAWN_DELAY: float = 2.0

# ── Bubble gun constants ───────────────────────────────────────────────────
const BUBBLE_COOLDOWN: float     = 3.0    # seconds between shots
const BUBBLE_ESCAPE_HITS: int    = 5      # face-button mashes to escape
const BUBBLE_FLOAT_VY: float     = -40.0  # upward drift while trapped
const BUBBLE_MAX_DURATION: float = 10.0   # auto-escape after this many seconds

## Horizontal offset from player centre when placing a block.
const BLOCK_PLACE_OFFSET: float = 32.0

# ── State machine ──────────────────────────────────────────────────────────
enum State { GROUND, AIR, WALL, DEAD, BUBBLED }
var _state: State = State.AIR

var _wall_dir: int = 0
var _facing:   int = 1  # Set to -1 for Player 2 (right side) in _ready()

# ── Platforming timers ─────────────────────────────────────────────────────
var _coyote_timer:      float = 0.0
var _jump_buffer_timer: float = 0.0
var _wall_jump_lock:    float = 0.0

# ── Health / combat ────────────────────────────────────────────────────────
var _health:        int   = 0
var _iframes_timer: float = 0.0
var _respawn_timer: float = 0.0
var _spawn_position: Vector2

# ── Bubble gun ────────────────────────────────────────────────────────────
var _shoot_cooldown: float = 0.0
var _bubble_hits:    int   = 0
var _bubble_timer:   float = 0.0

# ── Per-frame joypad edge detection ───────────────────────────────────────
## Buttons pressed/released this physics frame; cleared at end of _physics_process.
var _joy_just_pressed:  Dictionary = {}
var _joy_just_released: Dictionary = {}

# ── Scene references ───────────────────────────────────────────────────────
## Controller device index: 0 = first physical gamepad, 1 = second.
@export var controller_device: int = 0
@export var solid_creation_scene:  PackedScene
@export var bouncy_creation_scene: PackedScene

var _bubble_scene: PackedScene = preload("res://scenes/objects/Bubble.tscn")

@onready var _sprite: AnimatedSprite2D = $Sprite
var _gun_sprite: Sprite2D = null
var _bubble_trap_visual: Node2D = null
var _escape_prompt_label: Label = null
var _escape_progress_bar: ProgressBar = null
var _escape_button_circle: Control = null
var _player_color: Color = Color.WHITE  # Reset color (no longer used for tinting)


func _ready() -> void:
	add_to_group("player")
	_spawn_position = position
	_health = GameState.max_player_stamina
	_sync_health_to_gamestate()
	floor_snap_length = 6.0
	if _sprite:
		_sprite.play("idle")
		# Set facing direction
		if controller_device == 0:
			_facing = 1  # Face right
		else:
			_facing = -1  # Face left toward other player
		_update_facing_visual()

	# Add P1/P2 indicator label above bubble
	var player_indicator = Label.new()
	player_indicator.text = "P1" if controller_device == 0 else "P2"
	player_indicator.add_theme_font_size_override("font_size", 16)
	player_indicator.position = Vector2(-8, -160)  # Well above bubble
	add_child(player_indicator)
	# Attach bubble-gun sprite at runtime (avoids modifying Player.tscn).
	var gun_tex := load("res://assets/sprites/s_bubble_gun.png")
	if gun_tex:
		_gun_sprite = Sprite2D.new()
		_gun_sprite.texture = gun_tex
		_gun_sprite.position = Vector2(8.0, -26.0)  # Higher up (was -20.0)
		_gun_sprite.scale = Vector2(1.5, 1.5)  # Bigger gun (1.5x size)
		_gun_sprite.z_index = 1
		add_child(_gun_sprite)
		# Add idle sway animation to gun
		var gun_sway = create_tween()
		gun_sway.set_loops()
		gun_sway.set_trans(Tween.TRANS_SINE)
		gun_sway.set_ease(Tween.EASE_IN_OUT)
		gun_sway.tween_property(_gun_sprite, "position:y", -26.0 - 4.0, 1.0)
		gun_sway.tween_property(_gun_sprite, "position:y", -26.0 + 4.0, 1.0)


# ── Joypad edge-detection via _input ──────────────────────────────────────

func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton):
		return
	if event.device != controller_device:
		return
	if event.pressed:
		_joy_just_pressed[event.button_index] = true
	else:
		_joy_just_released[event.button_index] = true


# ── Main loop ─────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		_tick_respawn(delta)
		_joy_just_pressed.clear()
		_joy_just_released.clear()
		return

	if _state == State.BUBBLED:
		_tick_bubble(delta)
		_joy_just_pressed.clear()
		_joy_just_released.clear()
		return

	_tick_timers(delta)
	_handle_meta_input()
	_apply_gravity(delta)
	_handle_movement_input(delta)
	_handle_weapon_input()
	_execute_movement()
	_update_state()
	_update_animation()
	_tick_iframes(delta)
	if _shoot_cooldown > 0.0:
		_shoot_cooldown -= delta
	_joy_just_pressed.clear()
	_joy_just_released.clear()


# ── Joypad helpers ─────────────────────────────────────────────────────────

func _joy_btn(btn: int) -> bool:
	return _joy_just_pressed.get(btn, false)

func _joy_btn_rel(btn: int) -> bool:
	return _joy_just_released.get(btn, false)

func _joy_left() -> bool:
	return (Input.get_joy_axis(controller_device, JOY_AXIS_LEFT_X) < -0.3
		or Input.is_joy_button_pressed(controller_device, JOY_BUTTON_DPAD_LEFT))

func _joy_right() -> bool:
	return (Input.get_joy_axis(controller_device, JOY_AXIS_LEFT_X) > 0.3
		or Input.is_joy_button_pressed(controller_device, JOY_BUTTON_DPAD_RIGHT))

func _joy_jump_held() -> bool:
	return Input.is_joy_button_pressed(controller_device, JOY_BUTTON_A)

## True if any face button (A/B/X/Y) was just pressed this frame.
func _joy_any_face() -> bool:
	return (_joy_btn(JOY_BUTTON_A) or _joy_btn(JOY_BUTTON_B)
		or _joy_btn(JOY_BUTTON_X) or _joy_btn(JOY_BUTTON_Y))


# ── Per-frame ticks ────────────────────────────────────────────────────────

func _tick_timers(delta: float) -> void:
	if _coyote_timer > 0.0:
		_coyote_timer -= delta
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer -= delta
	if _wall_jump_lock > 0.0:
		_wall_jump_lock -= delta


func _tick_iframes(delta: float) -> void:
	if _iframes_timer <= 0.0:
		if _sprite:
			_sprite.modulate.a = 1.0
		return
	_iframes_timer -= delta
	if _sprite:
		_sprite.modulate.a = 0.3 if fmod(_iframes_timer, 0.15) < 0.075 else 1.0


func _tick_respawn(delta: float) -> void:
	_respawn_timer -= delta
	if _sprite:
		_sprite.modulate = Color(1.0, 0.2, 0.2,
			0.5 + 0.5 * absf(sin(_respawn_timer * 6.0)))
	if _respawn_timer <= 0.0:
		_respawn()


func _tick_bubble(delta: float) -> void:
	# Create bobbing animation on first frame of bubble
	if _bubble_timer == 0.0 and _bubble_trap_visual:
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
	# Pulse blue tint while trapped.
	if _sprite:
		var pulse := 0.6 + 0.4 * absf(sin(_bubble_timer * 4.0))
		_sprite.modulate = Color(0.4, 0.7, 1.0, pulse)


# ── Input ──────────────────────────────────────────────────────────────────

func _handle_meta_input() -> void:
	# Only device-0 player triggers pause/restart to avoid double-firing.
	if controller_device == 0:
		if Input.is_action_just_pressed("pause"):
			GameState.toggle_pause()
		if Input.is_action_just_pressed("restart"):
			GameState.reset_level()
			get_tree().reload_current_scene()


func _handle_movement_input(delta: float) -> void:
	var left  := _joy_left()
	var right := _joy_right()

	if _joy_btn(JOY_BUTTON_A):
		_jump_buffer_timer = JUMP_BUFFER_TIME

	match _state:
		State.GROUND:
			_ground_move(left, right, delta)
			if _jump_buffer_timer > 0.0:
				_start_jump()
				_jump_buffer_timer = 0.0

		State.AIR:
			_air_move(left, right, delta)
			if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
				_start_jump()
				_coyote_timer = 0.0
				_jump_buffer_timer = 0.0
			# Variable jump height: cut velocity if A released early.
			if not _joy_jump_held() and velocity.y < MIN_JUMP_SPEED:
				velocity.y = MIN_JUMP_SPEED
			_handle_creation_input()

		State.WALL:
			_apply_wall_friction()
			if _jump_buffer_timer > 0.0:
				_wall_jump()
				_jump_buffer_timer = 0.0
			_handle_creation_input()

	if _state == State.GROUND:
		_handle_creation_input()


func _handle_creation_input() -> void:
	if GameState.creations_remaining <= 0:
		return
	if _joy_btn(JOY_BUTTON_LEFT_SHOULDER) and solid_creation_scene:
		_place_block(solid_creation_scene)
	elif _joy_btn(JOY_BUTTON_RIGHT_SHOULDER) and bouncy_creation_scene:
		_place_block(bouncy_creation_scene)


func _handle_weapon_input() -> void:
	if _shoot_cooldown > 0.0:
		return
	if _joy_btn(JOY_BUTTON_B):
		_shoot_bubble()
		_shoot_cooldown = BUBBLE_COOLDOWN


# ── Movement helpers ───────────────────────────────────────────────────────

func _ground_move(left: bool, right: bool, delta: float) -> void:
	if right and not left:
		velocity.x = _accelerate_toward(velocity.x,  MAX_SPEED, ACCELERATION * delta)
		_facing = 1
	elif left and not right:
		velocity.x = _accelerate_toward(velocity.x, -MAX_SPEED, ACCELERATION * delta)
		_facing = -1
	else:
		velocity.x = _apply_friction(velocity.x, FRICTION_COEFF)
	_update_facing_visual()


func _air_move(left: bool, right: bool, delta: float) -> void:
	var air_accel := ACCELERATION * 0.4 * delta
	if right and not left:
		velocity.x = _accelerate_toward(velocity.x,  MAX_SPEED, air_accel)
		_facing = 1
	elif left and not right:
		velocity.x = _accelerate_toward(velocity.x, -MAX_SPEED, air_accel)
		_facing = -1
	_update_facing_visual()


func _apply_wall_friction() -> void:
	if velocity.y > 0.0:
		velocity.y = _apply_friction(velocity.y, WALL_FRICTION_COEFF)


func _start_jump() -> void:
	velocity.y = JUMP_SPEED
	_state = State.AIR
	_coyote_timer = 0.0


func _wall_jump() -> void:
	velocity.x = -_wall_dir * WALL_JUMP_H
	velocity.y = WALL_JUMP_V
	_facing    = -_wall_dir
	_wall_jump_lock = WALL_JUMP_LOCK_TIME
	_state = State.AIR
	_update_facing_visual()
	if _sprite:
		_sprite.play("jump")


# ── Bubble gun ─────────────────────────────────────────────────────────────

func _shoot_bubble() -> void:
	var b: Node2D = _bubble_scene.instantiate()
	b.set("direction", Vector2(_facing, 0.0))
	b.set("shooter", self)
	b.global_position = global_position + Vector2(_facing * 20.0, -26.0)  # Match gun position
	get_parent().add_child(b)


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
	_bubble_trap_visual.position = Vector2(0, 0)  # Center on player
	# Use the existing bubble sprite, scaled up large to surround player
	_bubble_trap_visual.texture = load("res://assets/sprites/s_bubble.png")
	_bubble_trap_visual.scale = Vector2(6.0, 6.0)  # Large bubble that surrounds player
	_bubble_trap_visual.modulate = Color(0.6, 0.85, 1.0, 0.7)  # Light blue tint
	_bubble_trap_visual.z_index = -1  # Behind player
	add_child(_bubble_trap_visual)

	# Create escape prompt UI - visual button indicator
	# Create red circle background (B button color) - custom drawn circle at top-right
	_escape_button_circle = _create_circle_control(15, Color(1.0, 0.0, 0.0, 0.9))
	_escape_button_circle.position = Vector2(60, -75)  # Top-right of bubble, close to player
	add_child(_escape_button_circle)

	# Create label with just the button letter (centered on circle)
	_escape_prompt_label = Label.new()
	_escape_prompt_label.text = "B"
	_escape_prompt_label.add_theme_font_size_override("font_size", 24)
	_escape_prompt_label.position = Vector2(52, -69)  # Centered on circle (offset by label size)
	add_child(_escape_prompt_label)

	# Create progress bar
	_escape_progress_bar = ProgressBar.new()
	_escape_progress_bar.min_value = 0
	_escape_progress_bar.max_value = float(BUBBLE_ESCAPE_HITS)
	_escape_progress_bar.value = 0
	_escape_progress_bar.size = Vector2(80, 16)
	_escape_progress_bar.position = Vector2(-40, 50)  # Below player in bubble
	add_child(_escape_progress_bar)


func _exit_bubble() -> void:
	_state = State.AIR
	if _sprite:
		_sprite.modulate = _player_color
	if _bubble_trap_visual:
		_bubble_trap_visual.queue_free()
		_bubble_trap_visual = null
	if _escape_button_circle:
		_escape_button_circle.queue_free()
		_escape_button_circle = null
	if _escape_prompt_label:
		_escape_prompt_label.queue_free()
		_escape_prompt_label = null
	if _escape_progress_bar:
		_escape_progress_bar.queue_free()
		_escape_progress_bar = null


func _burst_bubble() -> void:
	"""Bubble hits ceiling or obstacle and bursts, releasing player."""
	_state = State.AIR
	velocity.y = -120.0  # Small upward bounce on burst
	if _sprite:
		_sprite.modulate = _player_color
	if _bubble_trap_visual:
		_bubble_trap_visual.queue_free()
		_bubble_trap_visual = null
	if _escape_button_circle:
		_escape_button_circle.queue_free()
		_escape_button_circle = null
	if _escape_prompt_label:
		_escape_prompt_label.queue_free()
		_escape_prompt_label = null
	if _escape_progress_bar:
		_escape_progress_bar.queue_free()
		_escape_progress_bar = null


# ── Physics ────────────────────────────────────────────────────────────────

func _apply_gravity(delta: float) -> void:
	if _state != State.GROUND:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)


func _execute_movement() -> void:
	move_and_slide()


# ── State machine ──────────────────────────────────────────────────────────

func _update_state() -> void:
	var was_grounded := (_state == State.GROUND)

	if is_on_floor():
		_coyote_timer = 0.0
		if not was_grounded and _jump_buffer_timer > 0.0:
			_jump_buffer_timer = 0.0
			_start_jump()
		else:
			_state = State.GROUND
	elif _wall_jump_lock <= 0.0 and is_on_wall() and velocity.y >= 0.0:
		_state = State.WALL
		_detect_wall_direction()
	else:
		if was_grounded:
			_coyote_timer = COYOTE_TIME
		_state = State.AIR


func _detect_wall_direction() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		_wall_dir = -int(sign(col.get_normal().x))
		break


# ── Health / combat ────────────────────────────────────────────────────────

func take_damage(amount: int, knockback_dir: int) -> void:
	"""Apply damage and knockback; ignored while invincible, dead, or bubbled."""
	if _iframes_timer > 0.0 or _state == State.DEAD or _state == State.BUBBLED:
		return
	_health -= amount
	_sync_health_to_gamestate()
	if _health <= 0:
		_die()
		return
	velocity.x = knockback_dir * KNOCKBACK_H
	velocity.y = KNOCKBACK_V
	_state = State.AIR
	_iframes_timer = IFRAMES_DURATION


func instant_kill() -> void:
	"""Kill the player immediately, bypassing invincibility frames."""
	if _state == State.DEAD:
		return
	_health = 0
	_sync_health_to_gamestate()
	_die()


func stomp_bounce() -> void:
	"""Upward bounce given after stomping an enemy."""
	velocity.y = STOMP_BOUNCE
	_state = State.AIR


func _die() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	_respawn_timer = DEATH_RESPAWN_DELAY
	if controller_device == 0:
		GameState.player1_died.emit()
	else:
		GameState.player2_died.emit()


func _respawn() -> void:
	_health = GameState.max_player_stamina
	_sync_health_to_gamestate()
	position = _spawn_position
	velocity = Vector2.ZERO
	_state = State.AIR
	_iframes_timer = IFRAMES_DURATION
	if _sprite:
		_sprite.modulate = _player_color
		_sprite.play("idle")
	if controller_device == 0:
		GameState.player1_respawned.emit()
	else:
		GameState.player2_respawned.emit()


func _sync_health_to_gamestate() -> void:
	"""Push this player's current health to the correct GameState slot."""
	if controller_device == 0:
		GameState.player1_stamina = _health
	else:
		GameState.player2_stamina = _health


# ── Block placement ────────────────────────────────────────────────────────

func _place_block(scene: PackedScene) -> void:
	var place_pos := position + Vector2(_facing * BLOCK_PLACE_OFFSET, 0.0)
	var query := PhysicsPointQueryParameters2D.new()
	query.position = place_pos
	query.exclude  = [self]
	if not get_world_2d().direct_space_state.intersect_point(query).is_empty():
		return
	var block := scene.instantiate() as Node2D
	block.position = place_pos
	get_tree().current_scene.add_child(block)
	GameState.creations_remaining -= 1


# ── Visual helpers ─────────────────────────────────────────────────────────

func _update_facing_visual() -> void:
	if _sprite:
		_sprite.flip_h = (_facing == -1)
	if _gun_sprite:
		_gun_sprite.flip_h = (_facing == -1)
		_gun_sprite.position.x = 8.0 * _facing


func _update_animation() -> void:
	if not _sprite:
		return
	match _state:
		State.GROUND:
			_sprite.play("walk" if absf(velocity.x) > 10.0 else "idle")
		State.AIR:
			_sprite.play("jump")
		State.WALL:
			_sprite.play("slide")


# ── Pure utility functions ─────────────────────────────────────────────────

static func _approach(current: float, target: float, increment: float) -> float:
	if current < target:
		return minf(current + increment, target)
	return maxf(current - increment, target)


static func _accelerate_toward(current: float, target_spd: float, accel: float) -> float:
	var diff := target_spd - current
	if absf(diff) <= accel:
		return target_spd
	return current + accel * signf(diff)


static func _apply_friction(value: float, coeff: float) -> float:
	var drag := coeff * absf(value)
	if absf(value) <= drag:
		return 0.0
	return value - signf(value) * drag


## Helper: create a circular control with given radius and color.
func _create_circle_control(radius: float, color: Color) -> Control:
	var circle = Control.new()
	circle.custom_minimum_size = Vector2(radius * 2, radius * 2)
	# Draw the circle when the control is rendered
	circle.draw.connect(func():
		circle.draw_circle(Vector2(radius, radius), radius, color)
	)
	return circle

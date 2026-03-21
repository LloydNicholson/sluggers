extends CharacterBody2D

## Sluggers – Player
##
## Physics-based platformer character with movement states:
##   GROUND  – walking, with friction-based deceleration
##   AIR     – in-flight (includes coyote-time window and jump buffering)
##   WALL    – sliding on a wall, reduced vertical friction and wall-jump
##   DEAD    – death animation; auto-respawns after DEATH_RESPAWN_DELAY
##
## Platforming improvements over original GML port:
##   - floor_snap_length fixes collision stepping on small ledges
##   - Coyote time: brief window after leaving ground where jump still works
##   - Jump buffering: pre-pressed jump fires on the next landing
##   - Wall-jump lock prevents re-sticking to the wall immediately
##   - Air acceleration raised to 40 % of ground (was 25 %)
##
## Block placement:
##   Z (create_solid)   – places a solid StaticBody2D platform
##   X (create_bouncy)  – places a bouncy Area2D that launches the player up

# ── Physics constants (all velocities in px/s, accelerations in px/s²) ────
const GRAVITY: float             = 2880.0   # 0.8 px/frame² × 60²
const MAX_FALL_SPEED: float      = 1200.0   # 20 px/frame × 60
const MAX_SPEED: float           = 600.0    # 10 px/frame × 60
const ACCELERATION: float        = 1800.0   # 0.5 px/frame² × 60² (used with delta)
const FRICTION_COEFF: float      = 0.2      # proportional, applied per physics frame
const WALL_FRICTION_COEFF: float = 0.08     # proportional, applied per physics frame
const JUMP_SPEED: float          = -1200.0  # -20 px/frame × 60
const MIN_JUMP_SPEED: float      = -480.0   # -8 px/frame × 60
const WALL_JUMP_H: float         = 480.0    # 8 px/frame × 60
const WALL_JUMP_V: float         = -960.0   # -16 px/frame × 60

# ── Platforming-feel constants ─────────────────────────────────────────────
const COYOTE_TIME: float         = 0.12   # s after leaving ground to still jump
const JUMP_BUFFER_TIME: float    = 0.12   # s before landing where jump is queued
const WALL_JUMP_LOCK_TIME: float = 0.25   # s after wall-jump before wall-slide re-engages

# ── Combat constants ───────────────────────────────────────────────────────
const KNOCKBACK_H: float         = 360.0   # px/s horizontal knockback on damage
const KNOCKBACK_V: float         = -360.0  # px/s upward knockback on damage
const IFRAMES_DURATION: float    = 1.2     # s of invincibility after being hit
## Minimum downward speed (px/s) the player must have to count as a stomp.
const STOMP_MIN_VY: float        = 50.0
const STOMP_BOUNCE: float        = -600.0  # upward velocity given after stomping

const DEATH_RESPAWN_DELAY: float = 2.0     # s before respawn after death

## Horizontal offset from player centre when placing a block.
const BLOCK_PLACE_OFFSET: float = 32.0

# ── State machine ──────────────────────────────────────────────────────────
enum State { GROUND, AIR, WALL, DEAD }
var _state: State = State.AIR

## Direction of the wall the player is currently touching (-1 = left, +1 = right).
var _wall_dir: int = 0

## Last horizontal facing direction (+1 = right, -1 = left).
var _facing: int = 1

# ── Platforming timers ─────────────────────────────────────────────────────
var _coyote_timer: float     = 0.0
var _jump_buffer_timer: float = 0.0
var _wall_jump_lock: float   = 0.0

# ── Health / combat ────────────────────────────────────────────────────────
var _health: int             = 0
var _iframes_timer: float    = 0.0
var _respawn_timer: float    = 0.0
var _spawn_position: Vector2

# ── Scene references ───────────────────────────────────────────────────────
@export var solid_creation_scene: PackedScene
@export var bouncy_creation_scene: PackedScene

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group("player")
	_spawn_position = position
	# Preserve current health across room warps; use full HP on a fresh game start.
	_health = GameState.player_stamina if GameState.player_stamina > 0 else GameState.max_player_stamina
	GameState.player_stamina = _health
	# Step-up collision: snap to floor over small ledges
	floor_snap_length = 6.0
	if _sprite:
		_sprite.play("idle")


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		_tick_respawn(delta)
		return

	_tick_timers(delta)
	_handle_meta_input()
	_apply_gravity(delta)
	_handle_movement_input(delta)
	_execute_movement()
	_update_state()
	_update_animation()
	_tick_iframes(delta)


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
	# Blink effect: alternate opacity every ~75 ms
	if _sprite:
		_sprite.modulate.a = 0.3 if fmod(_iframes_timer, 0.15) < 0.075 else 1.0


func _tick_respawn(delta: float) -> void:
	_respawn_timer -= delta
	# Pulse red while dead
	if _sprite:
		_sprite.modulate = Color(1.0, 0.2, 0.2, 0.5 + 0.5 * absf(sin(_respawn_timer * 6.0)))
	if _respawn_timer <= 0.0:
		_respawn()


# ── Input ──────────────────────────────────────────────────────────────────

func _handle_meta_input() -> void:
	if Input.is_action_just_pressed("pause"):
		GameState.toggle_pause()
	if Input.is_action_just_pressed("restart"):
		GameState.reset_level()
		get_tree().reload_current_scene()


func _handle_movement_input(delta: float) -> void:
	var left  := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")

	# Buffer the jump press so it can fire on the next landing.
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER_TIME

	match _state:
		State.GROUND:
			_ground_move(left, right, delta)
			if _jump_buffer_timer > 0.0:
				_start_jump()
				_jump_buffer_timer = 0.0

		State.AIR:
			_air_move(left, right, delta)
			# Coyote-time jump: recently left the ground and jump was buffered.
			if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
				_start_jump()
				_coyote_timer = 0.0
				_jump_buffer_timer = 0.0
			# Variable jump height: cut velocity if jump is released early.
			if not Input.is_action_pressed("jump") and velocity.y < MIN_JUMP_SPEED:
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
	if Input.is_action_just_pressed("create_solid") and solid_creation_scene:
		_place_block(solid_creation_scene)
	elif Input.is_action_just_pressed("create_bouncy") and bouncy_creation_scene:
		_place_block(bouncy_creation_scene)


# ── Movement helpers ───────────────────────────────────────────────────────

func _ground_move(left: bool, right: bool, delta: float) -> void:
	if right and not left:
		velocity.x = _accelerate_toward(velocity.x, MAX_SPEED, ACCELERATION * delta)
		_facing = 1
	elif left and not right:
		velocity.x = _accelerate_toward(velocity.x, -MAX_SPEED, ACCELERATION * delta)
		_facing = -1
	else:
		velocity.x = _apply_friction(velocity.x, FRICTION_COEFF)
	_update_facing_visual()


func _air_move(left: bool, right: bool, delta: float) -> void:
	# Air control is 40 % of ground acceleration (improved from original 25 %).
	var air_accel := ACCELERATION * 0.4 * delta
	if right and not left:
		velocity.x = _accelerate_toward(velocity.x, MAX_SPEED, air_accel)
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
	# Lock out wall-slide re-entry so the player can move away cleanly.
	_wall_jump_lock = WALL_JUMP_LOCK_TIME
	_state = State.AIR
	_update_facing_visual()
	# Play jump animation immediately rather than waiting for _update_animation.
	if _sprite:
		_sprite.play("jump")


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
		# Consume a buffered jump on the frame we land.
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
			# Just walked off an edge – open coyote window.
			_coyote_timer = COYOTE_TIME
		_state = State.AIR


func _detect_wall_direction() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		_wall_dir = -int(sign(col.get_normal().x))
		break


# ── Health / combat ────────────────────────────────────────────────────────

func take_damage(amount: int, knockback_dir: int) -> void:
	"""Apply damage and knockback; ignored while invincible or dead."""
	if _iframes_timer > 0.0 or _state == State.DEAD:
		return
	_health -= amount
	GameState.player_stamina = _health
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
	GameState.player_stamina = 0
	_die()


func stomp_bounce() -> void:
	"""Called when the player successfully stomps an enemy – gives an upward bounce."""
	velocity.y = STOMP_BOUNCE
	_state = State.AIR


func _die() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	_respawn_timer = DEATH_RESPAWN_DELAY
	GameState.player_died.emit()


func _respawn() -> void:
	_health = GameState.max_player_stamina
	GameState.player_stamina = _health
	position = _spawn_position
	velocity = Vector2.ZERO
	_state = State.AIR
	_iframes_timer = IFRAMES_DURATION
	if _sprite:
		_sprite.modulate = Color.WHITE
		_sprite.play("idle")
	GameState.player_respawned.emit()


# ── Block placement ────────────────────────────────────────────────────────

func _place_block(scene: PackedScene) -> void:
	var place_pos := position + Vector2(_facing * BLOCK_PLACE_OFFSET, 0.0)

	# Refuse to place if the target cell overlaps existing physics geometry.
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


func _update_animation() -> void:
	if not _sprite:
		return
	match _state:
		State.GROUND:
			if absf(velocity.x) > 10.0:
				_sprite.play("walk")
			else:
				_sprite.play("idle")
		State.AIR:
			_sprite.play("jump")
		State.WALL:
			_sprite.play("slide")


# ── Pure utility functions (mirrors of GML script equivalents) ─────────────

## Moves `current` toward `target` by at most `increment` per call.
## Equivalent to GML approach().
static func _approach(current: float, target: float, increment: float) -> float:
	if current < target:
		return minf(current + increment, target)
	return maxf(current - increment, target)


## Accelerates `current` toward `±max_spd` by `accel` per call.
## Equivalent to GML add_movement_maxspeed().
static func _accelerate_toward(current: float, target_spd: float, accel: float) -> float:
	var diff := target_spd - current
	if absf(diff) <= accel:
		return target_spd
	return current + accel * signf(diff)


## Applies a proportional friction force, bringing `value` toward zero.
## Equivalent to GML apply_friction_to_movement_entity().
static func _apply_friction(value: float, coeff: float) -> float:
	var drag := coeff * absf(value)
	if absf(value) <= drag:
		return 0.0
	return value - signf(value) * drag

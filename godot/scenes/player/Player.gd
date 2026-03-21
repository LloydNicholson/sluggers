extends CharacterBody2D

## Sluggers – Player
##
## Physics-based platformer character with three movement states:
##   GROUND  – walking, with friction-based deceleration
##   AIR     – in-flight with reduced horizontal control and variable jump height
##   WALL    – sliding on a wall, with reduced vertical friction and wall-jump
##
## Block placement:
##   Z (create_solid)   – places a solid StaticBody2D platform
##   X (create_bouncy)  – places a bouncy Area2D that launches the player up

# ── Physics constants (all velocities in px/s, accelerations in px/s²) ────
# Original GML values were in px/frame at 60 fps.  Multiply by 60 for px/s.
const GRAVITY: float             = 2880.0   # 0.8 px/frame² × 60 × 60
const MAX_FALL_SPEED: float      = 1200.0   # 20 px/frame × 60
const MAX_SPEED: float           = 600.0    # 10 px/frame × 60
const ACCELERATION: float        = 1800.0   # 0.5 px/frame² × 60 × 60 (used with delta)
const FRICTION_COEFF: float      = 0.2      # proportional, applied per physics frame
const WALL_FRICTION_COEFF: float = 0.08     # proportional, applied per physics frame
const JUMP_SPEED: float          = -1200.0  # -20 px/frame × 60
const MIN_JUMP_SPEED: float      = -480.0   # -8 px/frame × 60
const WALL_JUMP_H: float         = 480.0    # 8 px/frame × 60
const WALL_JUMP_V: float         = -960.0   # -16 px/frame × 60

## Horizontal offset from player centre when placing a block.
const BLOCK_PLACE_OFFSET: float = 32.0

# ── State machine ──────────────────────────────────────────────────────────
enum State { GROUND, AIR, WALL }
var _state: State = State.AIR

## Direction of the wall the player is currently touching (-1 = left, +1 = right).
var _wall_dir: int = 0

## Last horizontal facing direction (+1 = right, -1 = left).
var _facing: int = 1

# ── Scene references ───────────────────────────────────────────────────────
## Packed scenes assigned from the editor (or via Room scene).
@export var solid_creation_scene: PackedScene
@export var bouncy_creation_scene: PackedScene

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group("player")
	if _sprite:
		_sprite.play("idle")


func _physics_process(delta: float) -> void:
	_handle_meta_input()
	_apply_gravity(delta)
	_handle_movement_input(delta)
	_execute_movement()
	_update_state()
	_update_animation()


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
	var jump  := Input.is_action_just_pressed("jump")

	match _state:
		State.GROUND:
			_ground_move(left, right, delta)
			if jump:
				_start_jump()

		State.AIR:
			_air_move(left, right, delta)
			# Variable jump height: cut velocity if the jump button is released early.
			if not Input.is_action_pressed("jump") and velocity.y < MIN_JUMP_SPEED:
				velocity.y = MIN_JUMP_SPEED
			_handle_creation_input()

		State.WALL:
			_apply_wall_friction()
			if jump:
				_wall_jump()
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
	# Air control is 1/4 of ground acceleration (matches original GML).
	var air_accel := ACCELERATION * 0.25 * delta
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


func _wall_jump() -> void:
	velocity.x = -_wall_dir * WALL_JUMP_H
	velocity.y = WALL_JUMP_V
	_facing    = -_wall_dir
	_state     = State.AIR
	_update_facing_visual()


# ── Physics ────────────────────────────────────────────────────────────────

func _apply_gravity(delta: float) -> void:
	if _state != State.GROUND:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)


func _execute_movement() -> void:
	move_and_slide()


# ── State machine ──────────────────────────────────────────────────────────

func _update_state() -> void:
	if is_on_floor():
		_state = State.GROUND
	elif is_on_wall() and velocity.y >= 0.0:
		_state = State.WALL
		_detect_wall_direction()
	else:
		_state = State.AIR


func _detect_wall_direction() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		_wall_dir = -int(sign(col.get_normal().x))
		break


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

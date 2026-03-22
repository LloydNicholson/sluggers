extends Area2D

## Sluggers – Enemy
##
## A hazard that patrols horizontally between x_min and x_max.
## When the player enters detect_range the enemy switches to chase mode.
## The player can stomp the enemy from above to deal damage; otherwise the
## enemy deals damage with knockback when the player touches it.

## Left boundary of the patrol path (world x-coordinate).
@export var x_min: float = 0.0
## Right boundary of the patrol path (world x-coordinate).
@export var x_max: float = 100.0
## Patrol speed in pixels per second.
@export var speed: float = 60.0
## Chase speed in pixels per second (used when player is within detect_range).
@export var chase_speed: float = 120.0
## Radius within which the enemy switches from patrol to chase mode.
@export var detect_range: float = 160.0
## Starting health points.
@export var max_health: int = 1

var _direction: int = 1
var _health: int = 1

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _health_label: Label = $HealthLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_health = max_health
	_update_health_display()


func _physics_process(delta: float) -> void:
	var player := _find_player()
	if player and position.distance_to(player.position) < detect_range:
		_chase(player, delta)
	else:
		_patrol(delta)


# ── Movement ───────────────────────────────────────────────────────────────

func _patrol(delta: float) -> void:
	position.x += speed * _direction * delta
	if position.x >= x_max:
		position.x = x_max
		_direction = -1
		_sprite.flip_h = true
	elif position.x <= x_min:
		position.x = x_min
		_direction = 1
		_sprite.flip_h = false


func _chase(player: Node2D, delta: float) -> void:
	var dir := signf(player.position.x - position.x)
	position.x += chase_speed * dir * delta
	_sprite.flip_h = (dir < 0.0)


# ── Contact ────────────────────────────────────────────────────────────────

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	# Stomp check: player is above the enemy's centre and falling fast enough.
	# The 50 px/s threshold matches Player.STOMP_MIN_VY; the 8 px vertical gap
	# ensures the player's feet are clearly above the enemy's collision centre.
	const STOMP_VY_THRESHOLD: float = 50.0
	const STOMP_VERTICAL_OFFSET: float = 8.0
	var player_vel := (body as CharacterBody2D).velocity if body is CharacterBody2D else Vector2.ZERO
	if player_vel.y > STOMP_VY_THRESHOLD and body.position.y < position.y - STOMP_VERTICAL_OFFSET:
		take_damage(1)
		if body.has_method("stomp_bounce"):
			body.stomp_bounce()
	else:
		var knockback_dir := int(signf(body.position.x - position.x))
		if body.has_method("take_damage"):
			body.take_damage(1, knockback_dir)


# ── Health ─────────────────────────────────────────────────────────────────

func take_damage(amount: int) -> void:
	_health -= amount
	_update_health_display()
	if _health <= 0:
		queue_free()


func _update_health_display() -> void:
	if _health_label:
		_health_label.text = "♥".repeat(maxi(_health, 0))


# ── Helpers ────────────────────────────────────────────────────────────────

func _find_player() -> Node2D:
	var group := get_tree().get_nodes_in_group("player")
	return group[0] if not group.is_empty() else null

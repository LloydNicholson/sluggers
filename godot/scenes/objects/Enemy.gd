extends Area2D

## Sluggers – Enemy
##
## A hazard that patrols horizontally between x_min and x_max.
## Reloads the current scene (player death) when the player touches it.

## Left boundary of the patrol path (world x-coordinate).
@export var x_min: float = 0.0
## Right boundary of the patrol path (world x-coordinate).
@export var x_max: float = 100.0
## Patrol speed in pixels per second.
@export var speed: float = 60.0

var _direction: int = 1

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x += speed * _direction * delta
	if position.x >= x_max:
		position.x = x_max
		_direction = -1
		_sprite.flip_h = true
	elif position.x <= x_min:
		position.x = x_min
		_direction = 1
		_sprite.flip_h = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.reset_level()
		body.get_tree().reload_current_scene()

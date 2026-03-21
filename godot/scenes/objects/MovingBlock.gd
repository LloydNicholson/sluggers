extends AnimatableBody2D

## Sluggers – MovingBlock
##
## A horizontal platform that shuttles back and forth between x_min and x_max.
## Uses AnimatableBody2D so that CharacterBody2D nodes riding on top are
## correctly carried along (Godot's built-in platform-riding logic).

@export var x_min: float = 400.0
@export var x_max: float = 1000.0
## Movement speed in pixels per second.
@export var speed: float = 300.0

var _direction: int = 1


func _physics_process(delta: float) -> void:
	position.x += speed * _direction * delta
	if position.x >= x_max:
		position.x = x_max
		_direction = -1
	elif position.x <= x_min:
		position.x = x_min
		_direction = 1

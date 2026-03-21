extends Camera2D

## Sluggers – GameCamera
##
## Smoothly follows a target node using linear interpolation, preserving the
## same feel as the original GML camera that lerped at 0.1 per frame.
## The target is normally the Player node in the current room.
## Camera2D limit_* properties are respected: the lerp destination is clamped
## so the view never drifts outside the room boundaries.

## NodePath to the node this camera should follow (set per-room in the editor).
@export var target_path: NodePath = NodePath("")
## Interpolation speed (0 = no movement, 1 = instant snap).
@export_range(0.0, 1.0, 0.01) var lerp_speed: float = 0.1

var _target: Node2D = null


func _ready() -> void:
	if not target_path.is_empty():
		_target = get_node_or_null(target_path)


func _process(_delta: float) -> void:
	if _target == null:
		return
	var half := get_viewport_rect().size * 0.5
	var tx := clampf(_target.global_position.x, limit_left + half.x, limit_right - half.x)
	var ty := clampf(_target.global_position.y, limit_top + half.y, limit_bottom - half.y)
	global_position = global_position.lerp(Vector2(tx, ty), lerp_speed)

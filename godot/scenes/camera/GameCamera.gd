extends Camera2D

## Sluggers – GameCamera
##
## Smoothly follows the midpoint of all nodes in the "players" group using
## linear interpolation, preserving the same feel as the original GML camera
## (lerp at 0.1 per frame).  Falls back to a single target if only one player
## is present.  Camera2D limit_* properties are respected: the lerp destination
## is clamped so the view never drifts outside the room boundaries.

## Interpolation speed (0 = no movement, 1 = instant snap).
@export_range(0.0, 1.0, 0.01) var lerp_speed: float = 0.1


func _process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return

	# Compute midpoint of all living players.
	var sum := Vector2.ZERO
	for p in players:
		sum += (p as Node2D).global_position
	var target := sum / players.size()

	# Clamp so camera doesn't show outside room boundaries.
	var half := get_viewport_rect().size * 0.5
	var tx := clampf(target.x, limit_left  + half.x, limit_right  - half.x)
	var ty := clampf(target.y, limit_top   + half.y, limit_bottom - half.y)
	global_position = global_position.lerp(Vector2(tx, ty), lerp_speed)

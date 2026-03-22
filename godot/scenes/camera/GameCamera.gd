extends Camera2D

## Sluggers – GameCamera
##
## Smoothly follows the midpoint of all nodes in the "player" group using
## linear interpolation. In two-player mode, dynamically zooms out so both
## players remain visible (similar to Smash Bros-style framing).
## Falls back to a single target if only one player is present.
## Camera2D limit_* properties are respected: the lerp destination
## is clamped so the view never drifts outside the room boundaries.

## Interpolation speed (0 = no movement, 1 = instant snap).
@export_range(0.0, 1.0, 0.01) var lerp_speed: float = 0.1
## Zoom interpolation speed (0 = no change, 1 = instant snap).
@export_range(0.0, 1.0, 0.01) var zoom_lerp_speed: float = 0.05
## Padding (px) added around players when computing zoom.
@export var zoom_padding: float = 80.0
## Minimum zoom (0.5 = see double the viewport width).
@export var min_zoom: float = 0.5
## Maximum zoom (1.0 = native resolution).
@export var max_zoom: float = 1.0


func _process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	# Compute midpoint of all living players.
	var sum := Vector2.ZERO
	for p in players:
		sum += (p as Node2D).global_position
	var target := sum / players.size()

	# Dynamically zoom to keep all players in frame with padding.
	if players.size() >= 2:
		var max_spread_x := 0.0
		for p in players:
			max_spread_x = maxf(max_spread_x, absf((p as Node2D).global_position.x - target.x))
		var viewport_half_x := get_viewport_rect().size.x * 0.5
		var desired_zoom := viewport_half_x / (max_spread_x + zoom_padding)
		desired_zoom = clampf(desired_zoom, min_zoom, max_zoom)
		zoom = zoom.lerp(Vector2(desired_zoom, desired_zoom), zoom_lerp_speed)

	# Clamp so camera doesn't show outside room boundaries.
	var half := get_viewport_rect().size * 0.5 / zoom.x
	var tx := clampf(target.x, limit_left  + half.x, limit_right  - half.x)
	var ty := clampf(target.y, limit_top   + half.y, limit_bottom - half.y)
	global_position = global_position.lerp(Vector2(tx, ty), lerp_speed)

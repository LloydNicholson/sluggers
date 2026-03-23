extends Area2D

## Sluggers – Bubble projectile
##
## Fired by a player's bubble gun. Travels with a floating, sinusoidal
## arc (horizontal drift + vertical oscillation + slight upward float) until:
##   • hits the other player  → traps them in the BUBBLED state
##   • hits terrain/a wall    → pops (queue_free)
##   • leaves the screen      → pops (VisibleOnScreenNotifier2D)

const SPEED := 200.0
## Amplitude of the vertical sinusoidal wave (px).
const WAVE_AMPLITUDE := 10.0
## Frequency of the wave oscillation (cycles per second).
const WAVE_FREQUENCY := 2.0
## Gentle upward drift applied on top of the wave (px/s).
const UPWARD_DRIFT := 20.0

## Direction the bubble travels (set by the firing player).
var direction := Vector2.RIGHT
## The player who fired this bubble (excluded from self-hit detection).
var shooter: Node = null

var _time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)


func _physics_process(delta: float) -> void:
	_time += delta
	# Horizontal movement scaled by direction.
	var dx := direction.x * SPEED * delta
	# Sinusoidal vertical component gives the bubble a floating, wobbly path.
	# wave_velocity_y is the instantaneous vertical speed (px/s) from the wave.
	var wave_velocity_y := WAVE_AMPLITUDE * WAVE_FREQUENCY * cos(_time * WAVE_FREQUENCY * TAU)
	var dy := (wave_velocity_y - UPWARD_DRIFT) * delta
	position += Vector2(dx, dy)


func _on_body_entered(body: Node) -> void:
	# Ignore the player who shot it.
	if body == shooter:
		return
	# Trap any player that has the enter_bubble method.
	if body.has_method("enter_bubble"):
		body.enter_bubble()
	queue_free()

extends Area2D

## Sluggers – Bubble projectile
##
## Fired by a player's bubble gun. Travels horizontally until it:
##   • hits the other player  → traps them in the BUBBLED state
##   • hits terrain/a wall    → pops (queue_free)
##   • leaves the screen      → pops (VisibleOnScreenNotifier2D)

const SPEED := 250.0

## Direction the bubble travels (set by the firing player).
var direction := Vector2.RIGHT
## The player who fired this bubble (excluded from self-hit detection).
var shooter: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_body_entered(body: Node) -> void:
	# Ignore the player who shot it.
	if body == shooter:
		return
	# Trap any player that has the enter_bubble method.
	if body.has_method("enter_bubble"):
		body.enter_bubble()
	queue_free()

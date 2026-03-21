extends Area2D

## Sluggers – Diamond
##
## Collectible gem. Increments GameState.diamonds when touched by the player
## and then removes itself from the scene.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.diamonds += 1
		queue_free()

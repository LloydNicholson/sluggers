extends Area2D

## Sluggers – DeathArea
##
## An invisible kill zone (e.g. a pit or spike). Reloads the current scene
## when the player enters, effectively restarting the level.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.reset_level()
		body.get_tree().reload_current_scene()

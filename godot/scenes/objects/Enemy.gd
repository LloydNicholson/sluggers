extends Area2D

## Sluggers – Enemy
##
## A simple hazard. Reloads the current scene (player death) when the player
## touches it. Extend this script to add patrol movement or other behaviours.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.reset_level()
		body.get_tree().reload_current_scene()

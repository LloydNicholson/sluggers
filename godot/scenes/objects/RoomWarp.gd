extends Area2D

## Sluggers – RoomWarp
##
## Transitions the game to target_scene when the player enters this area.
## The player's spawn position in the destination room is controlled by
## placing the RoomWarp node near the matching entry point in that scene.

## Path to the destination scene (*.tscn), set in the editor.
@export_file("*.tscn") var target_scene: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not target_scene.is_empty():
		get_tree().change_scene_to_file(target_scene)

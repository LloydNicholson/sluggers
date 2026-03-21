extends Area2D

## Sluggers – BouncyCreation
##
## A player-placed bouncy platform. When a CharacterBody2D lands on it the
## body is launched upward with BOUNCE_FORCE, replicating the GML bounce object.
## Added to the "player_created" group so level-reset logic can remove it.

const BOUNCE_FORCE: float = -1500.0

func _ready() -> void:
	add_to_group("player_created")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = BOUNCE_FORCE

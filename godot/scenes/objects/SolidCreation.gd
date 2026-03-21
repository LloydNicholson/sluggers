extends StaticBody2D

## Sluggers – SolidCreation
##
## A player-placed solid platform. Acts as standard terrain once placed.
## Added to the "player_created" group for centralized cleanup on level reset.

func _ready() -> void:
	add_to_group("player_created")

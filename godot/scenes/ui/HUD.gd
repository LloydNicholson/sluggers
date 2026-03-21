extends CanvasLayer

## Sluggers – HUD
##
## Displays the game timer, collected diamonds, and remaining block-creation
## budget. Connects to GameState signals so values update reactively.

@onready var _timer_label: Label     = $Panel/VBox/TimerLabel
@onready var _diamond_label: Label   = $Panel/VBox/DiamondLabel
@onready var _creation_label: Label  = $Panel/VBox/CreationLabel


func _ready() -> void:
	GameState.timer_updated.connect(_on_timer_updated)
	GameState.diamonds_changed.connect(_on_diamonds_changed)
	GameState.creations_changed.connect(_on_creations_changed)
	_refresh_all()


func _refresh_all() -> void:
	_on_timer_updated(GameState.minutes, int(GameState.seconds))
	_on_diamonds_changed(GameState.diamonds)
	_on_creations_changed(GameState.creations_remaining)


func _on_timer_updated(mins: int, secs: int) -> void:
	_timer_label.text = "%02d:%02d" % [mins, secs]


func _on_diamonds_changed(count: int) -> void:
	_diamond_label.text = "Diamonds: %d" % count


func _on_creations_changed(remaining: int) -> void:
	_creation_label.text = "Creations: %d" % remaining

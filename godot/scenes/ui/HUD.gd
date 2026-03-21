extends CanvasLayer

## Sluggers – HUD
##
## Displays the level name, player health, game timer, collected diamonds,
## and remaining block-creation budget. Also shows a full-screen respawn
## overlay when the player dies, hiding it automatically on respawn.
## Connects to GameState signals so values update reactively.

@onready var _level_label: Label    = $StatsPanel/VBox/LevelLabel
@onready var _health_label: Label   = $StatsPanel/VBox/HealthLabel
@onready var _timer_label: Label    = $StatsPanel/VBox/TimerLabel
@onready var _diamond_label: Label  = $StatsPanel/VBox/DiamondLabel
@onready var _creation_label: Label = $StatsPanel/VBox/CreationLabel
@onready var _respawn_overlay: ColorRect = $RespawnOverlay


func _ready() -> void:
	GameState.timer_updated.connect(_on_timer_updated)
	GameState.diamonds_changed.connect(_on_diamonds_changed)
	GameState.creations_changed.connect(_on_creations_changed)
	GameState.health_changed.connect(_on_health_changed)
	GameState.player_died.connect(_on_player_died)
	GameState.player_respawned.connect(_on_player_respawned)
	_level_label.text = get_parent().name
	_refresh_all()


func _refresh_all() -> void:
	_on_timer_updated(GameState.minutes, int(GameState.seconds))
	_on_diamonds_changed(GameState.diamonds)
	_on_creations_changed(GameState.creations_remaining)
	_on_health_changed(GameState.player_stamina, GameState.max_player_stamina)


func _on_timer_updated(mins: int, secs: int) -> void:
	_timer_label.text = "%02d:%02d" % [mins, secs]


func _on_diamonds_changed(count: int) -> void:
	_diamond_label.text = "Diamonds: %d" % count


func _on_creations_changed(remaining: int) -> void:
	_creation_label.text = "Creations: %d" % remaining


func _on_health_changed(current: int, maximum: int) -> void:
	_health_label.text = "♥".repeat(current) + "♡".repeat(maximum - current)
	if current > 0 and _respawn_overlay.visible:
		_respawn_overlay.visible = false


func _on_player_died() -> void:
	_respawn_overlay.visible = true


func _on_player_respawned() -> void:
	_respawn_overlay.visible = false

extends CanvasLayer

## Sluggers – HUD
##
## Displays the level name, both players' health, game timer, collected
## diamonds, and remaining block-creation budget. Shows a per-player
## respawn overlay when a player dies, hiding it automatically on respawn.
## Connects to GameState signals so values update reactively.

@onready var _level_label: Label    = $StatsPanel/VBox/LevelLabel
@onready var _p1_health_label: Label = $StatsPanel/VBox/P1HealthLabel
@onready var _p2_health_label: Label = $StatsPanel/VBox/P2HealthLabel
@onready var _timer_label: Label    = $StatsPanel/VBox/TimerLabel
@onready var _diamond_label: Label  = $StatsPanel/VBox/DiamondLabel
@onready var _creation_label: Label = $StatsPanel/VBox/CreationLabel
@onready var _p1_respawn_overlay: ColorRect = $P1RespawnOverlay
@onready var _p2_respawn_overlay: ColorRect = $P2RespawnOverlay


func _ready() -> void:
	GameState.timer_updated.connect(_on_timer_updated)
	GameState.diamonds_changed.connect(_on_diamonds_changed)
	GameState.creations_changed.connect(_on_creations_changed)
	GameState.health_changed_player1.connect(_on_p1_health_changed)
	GameState.health_changed_player2.connect(_on_p2_health_changed)
	GameState.player1_died.connect(_on_player1_died)
	GameState.player1_respawned.connect(_on_player1_respawned)
	GameState.player2_died.connect(_on_player2_died)
	GameState.player2_respawned.connect(_on_player2_respawned)
	_level_label.text = get_parent().name
	_refresh_all()


func _refresh_all() -> void:
	_on_timer_updated(GameState.minutes, int(GameState.seconds))
	_on_diamonds_changed(GameState.diamonds)
	_on_creations_changed(GameState.creations_remaining)
	_on_p1_health_changed(GameState.player1_stamina, GameState.max_player_stamina)
	_on_p2_health_changed(GameState.player2_stamina, GameState.max_player_stamina)


func _on_timer_updated(mins: int, secs: int) -> void:
	_timer_label.text = "%02d:%02d" % [mins, secs]


func _on_diamonds_changed(count: int) -> void:
	_diamond_label.text = "Diamonds: %d" % count


func _on_creations_changed(remaining: int) -> void:
	_creation_label.text = "Creations: %d" % remaining


func _on_p1_health_changed(current: int, maximum: int) -> void:
	_p1_health_label.text = "P1: " + "♥".repeat(current) + "♡".repeat(maximum - current)
	if current > 0 and _p1_respawn_overlay.visible:
		_p1_respawn_overlay.visible = false


func _on_p2_health_changed(current: int, maximum: int) -> void:
	_p2_health_label.text = "P2: " + "♥".repeat(current) + "♡".repeat(maximum - current)
	if current > 0 and _p2_respawn_overlay.visible:
		_p2_respawn_overlay.visible = false


func _on_player1_died() -> void:
	_p1_respawn_overlay.visible = true


func _on_player1_respawned() -> void:
	_p1_respawn_overlay.visible = false


func _on_player2_died() -> void:
	_p2_respawn_overlay.visible = true


func _on_player2_respawned() -> void:
	_p2_respawn_overlay.visible = false

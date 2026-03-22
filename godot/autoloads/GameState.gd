extends Node

## Sluggers – GameState (Autoload)
##
## Global singleton that holds all persistent game data:
## pause state, elapsed timer, diamond counter, player-creation resources,
## and stamina. Emits signals so the HUD and other nodes can react reactively
## without polling.

signal paused
signal resumed
signal diamonds_changed(count: int)
signal creations_changed(remaining: int)
signal timer_updated(minutes: int, seconds: int)
signal health_changed(current: int, maximum: int)
signal player_died
signal player_respawned

# ── Pause ──────────────────────────────────────────────────────────────────
var is_paused: bool = false

# ── Timer ──────────────────────────────────────────────────────────────────
var minutes: int = 0
var seconds: float = 0.0
var _last_timer_minute: int = -1
var _last_timer_second: int = -1

# ── Collectibles ───────────────────────────────────────────────────────────
var diamonds: int = 0:
	set(value):
		diamonds = max(value, 0)
		diamonds_changed.emit(diamonds)

# ── Block-creation resources ───────────────────────────────────────────────
var creations_allowed: int = 5
var creations_remaining: int = 5:
	set(value):
		creations_remaining = clampi(value, 0, creations_allowed)
		creations_changed.emit(creations_remaining)

# ── Stamina / health ───────────────────────────────────────────────────────
var player_stamina: int = 4:
	set(value):
		player_stamina = clampi(value, 0, max_player_stamina)
		health_changed.emit(player_stamina, max_player_stamina)
var max_player_stamina: int = 4

# ── Difficulty (0 = Easy, 1 = Medium, 2 = Extreme) ────────────────────────
var enemy_difficulty: int = 1

# ── Audio volumes (linear 0–1) ─────────────────────────────────────────────
var master_volume: float = 1.0
var sound_volume: float = 1.0
var music_volume: float = 1.0


func _process(delta: float) -> void:
	if is_paused:
		return
	seconds += delta
	if seconds >= 60.0:
		seconds -= 60.0
		minutes += 1
	var displayed_second: int = int(seconds)
	if minutes != _last_timer_minute or displayed_second != _last_timer_second:
		_last_timer_minute = minutes
		_last_timer_second = displayed_second
		timer_updated.emit(minutes, displayed_second)


# ── Pause control ──────────────────────────────────────────────────────────

func toggle_pause() -> void:
	if is_paused:
		resume()
	else:
		pause()


func pause() -> void:
	is_paused = true
	get_tree().paused = true
	paused.emit()


func resume() -> void:
	is_paused = false
	get_tree().paused = false
	resumed.emit()


# ── Level reset ────────────────────────────────────────────────────────────

func reset_level() -> void:
	"""Call when restarting the current level to restore per-level state."""
	for node in get_tree().get_nodes_in_group("player_created"):
		node.queue_free()
	creations_remaining = creations_allowed
	player_stamina = max_player_stamina


func reset_game() -> void:
	"""Call when starting a full new game."""
	if is_paused:
		resume()
	minutes = 0
	seconds = 0.0
	_last_timer_minute = -1
	_last_timer_second = -1
	diamonds = 0
	timer_updated.emit(0, 0)
	reset_level()

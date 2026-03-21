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

# ── Pause ──────────────────────────────────────────────────────────────────
var is_paused: bool = false

# ── Timer ──────────────────────────────────────────────────────────────────
var minutes: int = 0
var seconds: float = 0.0

# ── Collectibles ───────────────────────────────────────────────────────────
var diamonds: int = 0:
	set(value):
		diamonds = value
		diamonds_changed.emit(diamonds)

# ── Block-creation resources ───────────────────────────────────────────────
var creations_allowed: int = 5
var creations_remaining: int = 5:
	set(value):
		creations_remaining = value
		creations_changed.emit(creations_remaining)

# ── Stamina ────────────────────────────────────────────────────────────────
var player_stamina: int = 4
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
	timer_updated.emit(minutes, int(seconds))


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
	creations_remaining = creations_allowed
	player_stamina = max_player_stamina


func reset_game() -> void:
	"""Call when starting a full new game."""
	if is_paused:
		resume()
	minutes = 0
	seconds = 0.0
	diamonds = 0
	reset_level()

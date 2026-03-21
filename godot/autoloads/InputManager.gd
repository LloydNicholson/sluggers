extends Node

## Sluggers – InputManager (Autoload)
##
## Wraps Godot's built-in InputMap to expose human-readable action labels and
## support runtime key-rebinding (used by the Controls page of the pause menu).

# ── Action registry ────────────────────────────────────────────────────────

## Maps action name → display label shown in the Controls menu.
const ACTION_LABELS: Dictionary = {
	"move_left":    "Move Left",
	"move_right":   "Move Right",
	"jump":         "Jump",
	"create_solid": "Create Solid Block",
	"create_bouncy":"Create Bouncy Block",
	"pause":        "Pause",
	"restart":      "Restart Level",
}


# ── Helpers ────────────────────────────────────────────────────────────────

func get_action_key_text(action: String) -> String:
	"""Returns a human-readable label for the first keyboard binding of action."""
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.as_text_keycode()
	return "(unbound)"


func rebind_action(action: String, new_event: InputEventKey) -> void:
	"""Replaces the first keyboard event bound to action with new_event."""
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
			break
	InputMap.action_add_event(action, new_event)


func get_all_action_bindings() -> Dictionary:
	"""Returns a dictionary of action → current key label for all tracked actions."""
	var result: Dictionary = {}
	for action in ACTION_LABELS:
		result[action] = get_action_key_text(action)
	return result

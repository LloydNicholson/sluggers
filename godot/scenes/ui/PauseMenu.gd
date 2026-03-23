extends CanvasLayer

## Sluggers – PauseMenu
##
## Multi-page pause overlay with the following pages:
##   MAIN        – Resume / Settings / Quit
##   SETTINGS    – Audio / Difficulty / Graphics / Controls
##   AUDIO       – Master, Music, and Sound-effects volume sliders
##   DIFFICULTY  – Enemy difficulty and ally strength
##   GRAPHICS    – Resolution and window mode
##   CONTROLS    – Rebindable key bindings
##
## The node tree is hidden until GameState emits the `paused` signal.
## All sub-pages live as VBoxContainer children of $Menu and are toggled
## by _navigate_to().

enum Page { MAIN, SETTINGS, AUDIO, DIFFICULTY, GRAPHICS, CONTROLS }

@onready var _overlay:          ColorRect       = $Overlay
@onready var _main_page:        VBoxContainer   = $Menu/MainPage
@onready var _settings_page:    VBoxContainer   = $Menu/SettingsPage
@onready var _audio_page:       VBoxContainer   = $Menu/AudioPage
@onready var _difficulty_page:  VBoxContainer   = $Menu/DifficultyPage
@onready var _graphics_page:    VBoxContainer   = $Menu/GraphicsPage
@onready var _controls_page:    VBoxContainer   = $Menu/ControlsPage

var _current_page: Page = Page.MAIN
## Tracks which action is waiting for a new key press during rebinding.
var _rebinding_action: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.paused.connect(_show_menu)
	GameState.resumed.connect(_hide_menu)
	_connect_ui_signals()
	hide()


# ── Visibility ─────────────────────────────────────────────────────────────

func _show_menu() -> void:
	show()
	_navigate_to(Page.MAIN)


func _hide_menu() -> void:
	hide()


# ── Page navigation ────────────────────────────────────────────────────────

func _navigate_to(page: Page) -> void:
	_current_page = page
	_main_page.visible        = page == Page.MAIN
	_settings_page.visible    = page == Page.SETTINGS
	_audio_page.visible       = page == Page.AUDIO
	_difficulty_page.visible  = page == Page.DIFFICULTY
	_graphics_page.visible    = page == Page.GRAPHICS
	_controls_page.visible    = page == Page.CONTROLS
	if page == Page.CONTROLS:
		_refresh_controls_page()
	# Auto-focus first button so keyboard/controller can interact immediately.
	match page:
		Page.MAIN:       $Menu/MainPage/ResumeButton.grab_focus()
		Page.SETTINGS:   $Menu/SettingsPage/AudioButton.grab_focus()
		Page.AUDIO:      $Menu/AudioPage/BackButton_Audio.grab_focus()
		Page.DIFFICULTY: $Menu/DifficultyPage/BackButton_Difficulty.grab_focus()
		Page.GRAPHICS:   $Menu/GraphicsPage/BackButton_Graphics.grab_focus()
		Page.CONTROLS:   $Menu/ControlsPage/BackButton_Controls.grab_focus()


# ── MAIN PAGE signals ──────────────────────────────────────────────────────

func _on_resume_pressed() -> void:
	GameState.resume()


func _on_settings_pressed() -> void:
	_navigate_to(Page.SETTINGS)


func _on_quit_pressed() -> void:
	get_tree().quit()


# ── SETTINGS PAGE signals ──────────────────────────────────────────────────

func _on_audio_pressed() -> void:
	_navigate_to(Page.AUDIO)


func _on_difficulty_pressed() -> void:
	_navigate_to(Page.DIFFICULTY)


func _on_graphics_pressed() -> void:
	_navigate_to(Page.GRAPHICS)


func _on_controls_pressed() -> void:
	_navigate_to(Page.CONTROLS)


func _on_back_pressed() -> void:
	if _current_page == Page.MAIN:
		GameState.resume()
	else:
		_navigate_to(Page.MAIN)


# ── AUDIO PAGE signals ─────────────────────────────────────────────────────

func _on_master_volume_changed(value: float) -> void:
	GameState.master_volume = value
	_set_bus_volume("Master", value)


func _on_music_volume_changed(value: float) -> void:
	GameState.music_volume = value
	_set_bus_volume("Music", value)


func _on_sound_volume_changed(value: float) -> void:
	GameState.sound_volume = value
	_set_bus_volume("Sounds", value)


# ── DIFFICULTY PAGE signals ────────────────────────────────────────────────

func _on_difficulty_option_selected(index: int) -> void:
	GameState.enemy_difficulty = index


# ── GRAPHICS PAGE signals ──────────────────────────────────────────────────

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_resolution_selected(index: int) -> void:
	var resolutions: Array[Vector2i] = [
		Vector2i(768,  432),
		Vector2i(1152, 648),
		Vector2i(1536, 864),
		Vector2i(1920, 1080),
	]
	if index < resolutions.size():
		DisplayServer.window_set_size(resolutions[index])


# ── CONTROLS PAGE ──────────────────────────────────────────────────────────

func _refresh_controls_page() -> void:
	"""Update each button label to show the current binding."""
	var bindings := InputManager.get_all_action_bindings()
	for child in _controls_page.get_children():
		if child is Button and child.has_meta("_action"):
			var action: String = child.get_meta("_action")
			child.text = "%s: %s" % [
				InputManager.ACTION_LABELS.get(action, action),
				bindings.get(action, "(unbound)")]


func _on_rebind_button_pressed(action: String) -> void:
	_rebinding_action = action


func _input(event: InputEvent) -> void:
	if not visible:
		return
	# ESC or controller Start closes the menu (when not mid-rebind).
	if _rebinding_action.is_empty():
		if event is InputEventKey and event.pressed and not event.echo \
				and event.keycode == KEY_ESCAPE:
			GameState.resume()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventJoypadButton and event.pressed \
				and event.button_index == JOY_BUTTON_START:
			GameState.resume()
			get_viewport().set_input_as_handled()
			return
		# Controller A button presses focused button
		if event is InputEventJoypadButton and event.pressed \
				and event.button_index == JOY_BUTTON_A:
			var focused = get_viewport().gui_get_focus_owner()
			if focused and focused is Button:
				focused.emit_signal("pressed")
				get_viewport().set_input_as_handled()
			return
		# Controller D-pad up/down for navigation
		if event is InputEventJoypadButton and event.pressed:
			var focused := get_viewport().gui_get_focus_owner()
			if event.button_index == JOY_BUTTON_DPAD_UP:
				if focused:
					focused.find_prev_valid_focus().grab_focus()
				get_viewport().set_input_as_handled()
				return
			if event.button_index == JOY_BUTTON_DPAD_DOWN:
				if focused:
					focused.find_next_valid_focus().grab_focus()
				get_viewport().set_input_as_handled()
				return
	if _rebinding_action.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		InputManager.rebind_action(_rebinding_action, event)
		_rebinding_action = ""
		_refresh_controls_page()
		get_viewport().set_input_as_handled()


func _connect_ui_signals() -> void:
	$Menu/MainPage/ResumeButton.pressed.connect(_on_resume_pressed)
	$Menu/MainPage/SettingsButton.pressed.connect(_on_settings_pressed)
	$Menu/MainPage/QuitButton.pressed.connect(_on_quit_pressed)

	$Menu/SettingsPage/AudioButton.pressed.connect(_on_audio_pressed)
	$Menu/SettingsPage/DifficultyButton.pressed.connect(_on_difficulty_pressed)
	$Menu/SettingsPage/GraphicsButton.pressed.connect(_on_graphics_pressed)
	$Menu/SettingsPage/ControlsButton.pressed.connect(_on_controls_pressed)
	$Menu/SettingsPage/BackButton_Settings.pressed.connect(_on_back_pressed)

	$Menu/AudioPage/MasterSlider.value_changed.connect(_on_master_volume_changed)
	$Menu/AudioPage/MusicSlider.value_changed.connect(_on_music_volume_changed)
	$Menu/AudioPage/SoundSlider.value_changed.connect(_on_sound_volume_changed)
	$Menu/AudioPage/BackButton_Audio.pressed.connect(_on_back_pressed)

	$Menu/DifficultyPage/DifficultyOption.item_selected.connect(_on_difficulty_option_selected)
	$Menu/DifficultyPage/BackButton_Difficulty.pressed.connect(_on_back_pressed)

	$Menu/GraphicsPage/FullscreenCheck.toggled.connect(_on_fullscreen_toggled)
	$Menu/GraphicsPage/ResolutionOption.item_selected.connect(_on_resolution_selected)
	$Menu/GraphicsPage/BackButton_Graphics.pressed.connect(_on_back_pressed)

	$Menu/ControlsPage/BackButton_Controls.pressed.connect(_on_back_pressed)
	for child in _controls_page.get_children():
		if child is Button and child.has_meta("_action"):
			var action: String = child.get_meta("_action")
			child.pressed.connect(_on_rebind_button_pressed.bind(action))


func _set_bus_volume(primary_bus: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(primary_bus)
	if bus_index == -1:
		bus_index = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

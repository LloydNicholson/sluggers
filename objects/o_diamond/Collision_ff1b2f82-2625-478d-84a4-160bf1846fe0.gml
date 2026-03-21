global.diamonds += 1;
global.diamond_combo += 1;
global.diamond_combo_timer = room_speed * global.diamond_combo_window_seconds;
if global.diamond_combo > 1 {
	global.player_score += global.diamond_combo * global.diamond_combo_score_multiplier;
}
instance_destroy(self);

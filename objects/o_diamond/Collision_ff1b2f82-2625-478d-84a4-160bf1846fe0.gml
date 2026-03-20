global.diamonds += 1;
global.diamond_combo += 1;
global.diamond_combo_timer = room_speed * 2;
if global.diamond_combo > 1 {
	global.player_score += global.diamond_combo * 10;
}
instance_destroy(self);

if global.pause {
	if keyboard_check_pressed(global.escape_key) || gamepad_button_check_pressed(0, global.escape_pad) {
		resume_game();
	} 
} else {	
	check_world_time();
	
	if keyboard_check_pressed(global.escape_key) || gamepad_button_check_pressed(0, global.escape_pad) {
		pause_game();	
	}
} 

if keyboard_check_pressed(ord("R")) {
	game_restart();
}


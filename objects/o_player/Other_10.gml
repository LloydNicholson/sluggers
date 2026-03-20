/// @desc Air

// Coyote time countdown (grace period to jump after walking off ledge)
if coyote_time_ > 0 {
	coyote_time_--;
}

// Jump buffer countdown
if jump_buffer_ > 0 {
	jump_buffer_--;
}

// Coyote jump
if coyote_time_ > 0 {
	if keyboard_check_pressed(global.up_key) || gamepad_button_check_pressed(0, global.up_pad) {
		vspeed_ = -jump_speed_;
		coyote_time_ = 0;
		jump_buffer_ = 0;
		target_yscale_ = 0.65;
		target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 1.35;
	}
}

player_jump_height();
air_player_move();

// Squash/stretch based on vertical speed
if vspeed_ < -4 {
	target_yscale_ = 1.2;
	target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 0.85;
} else if vspeed_ > 4 {
	target_yscale_ = 0.85;
	target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 1.1;
}

// Change to ground state - landing squash
if place_meeting(x, y + 1, collision_object_) {
	state = GROUND;
	target_yscale_ = 0.6;
	target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 1.4;
}

// Change to wall state
if (place_meeting(x + 1, y, collision_object_)) || (place_meeting(x - 1, y, collision_object_)) {
	state = WALL;
}

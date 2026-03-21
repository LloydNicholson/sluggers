// Add to jump buffer on press
if keyboard_check_pressed(global.up_key) || gamepad_button_check_pressed(0, global.up_pad) {
	jump_buffer_ = jump_buffer_frames_;
}

// Execute jump when buffer is active (called from GROUND state)
if jump_buffer_ > 0 {
	vspeed_ = -jump_speed_;
	jump_buffer_ = 0;
	coyote_time_ = 0;
	state = AIR;
	// Takeoff squash
	target_yscale_ = 0.65;
	target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 1.35;
}

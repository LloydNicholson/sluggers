sprite_index = left_slide_index_;
image_speed = 0;

// Face away from wall
if place_meeting(x + 1, y, collision_object_) {
	image_xscale = -abs(image_xscale);
} else {
	image_xscale = abs(image_xscale);
}

if keyboard_check_pressed(global.up_key) || gamepad_button_check_pressed(0, global.up_pad) {
	// Jump away from wall with strong horizontal kick
	var _wall_dir = place_meeting(x + 1, y, collision_object_) ? -1 : 1;
	vspeed_ = -jump_speed_;
	hspeed_ = _wall_dir * max_speed_ * 0.9;
	state = AIR;
	target_yscale_ = 0.65;
	target_xscale_ = _wall_dir * 1.35;
}
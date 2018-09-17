sprite_index = left_slide_index_;
image_speed = 0;
if hspeed_ > 0 {
	image_xscale = -1;
} else {
	image_xscale = 1;	
}

if keyboard_check_pressed(global.up_key) || gamepad_button_check_pressed(0, global.up_pad) {
	set_movement(-direction, -jump_speed_, 10);	
}
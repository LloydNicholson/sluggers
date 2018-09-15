if keyboard_check_pressed(global.up_key) || gamepad_button_check_pressed(0, global.up_pad) {
	vspeed_ = -jump_speed_;
	image_yscale = lerp(image_yscale, image_yscale*0.8, 0.8);
	// add jump audio 
			
} else {
	image_yscale = 1;	
}
	
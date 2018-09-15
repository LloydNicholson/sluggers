if (keyboard_check_released(global.up_key) || gamepad_button_check_released(0, global.up_pad)) && (vspeed_ < vspeed_/3) {
	vspeed_ = vspeed_/3;
}
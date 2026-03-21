sprite_index = jump_index_;
image_speed = 0;

// Keep facing direction based on movement
if hspeed_ > 0 {
	image_xscale = abs(image_xscale);
} else if hspeed_ < 0 {
	image_xscale = -abs(image_xscale);
}

if hspeed_ != 0 {
	sprite_index = walk_right_;
	// Speed up animation with movement speed
	image_speed = 0.8 + abs(hspeed_) * 0.08;

	if hspeed_ > 0 {
		image_xscale = abs(image_xscale);
	} else {
		image_xscale = -abs(image_xscale);
	}
} else {
	sprite_index = stand_index_;
	image_speed = 1;
}
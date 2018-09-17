if hspeed_ != 0 {
	sprite_index = walk_right_;
	image_speed = 1.2;
	
	if hspeed_ > 0 {
		image_xscale = 1;
	} else {
		image_xscale = -1;	
	}
} else {
	sprite_index = stand_index_;
	image_speed = 2;	
}
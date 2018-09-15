if instance_exists(o_player) {
	if x >= x_max-block_width {
		hspeed_ = -hspeed_;
	} else if x <= x_min {
		hspeed_ = -hspeed_;	
	}

	x += hspeed_;
	
	// Check for collision on top of block
	var inst = instance_place(x, y-1, o_player);
	if inst != noone {
		inst.hspeed_ = hspeed_;	
	} 
}

show_debug_message(hspeed_);

